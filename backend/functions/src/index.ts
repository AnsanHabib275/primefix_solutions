import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import * as crypto from 'crypto';
admin.initializeApp();

const cfg = functions.config();
const stripeKey = (cfg.stripe && cfg.stripe.secret_key) || '';
const stripe = new Stripe(stripeKey, { apiVersion: '2024-06-20' });

function toMinorUnitPKR(amount: number) { return amount * 100; }
function fmtDateTime(date: Date) {
  const p = (n: number) => n.toString().padStart(2,'0');
  const y = date.getFullYear();
  const m = p(date.getMonth()+1);
  const d = p(date.getDate());
  const hh = p(date.getHours());
  const mm = p(date.getMinutes());
  const ss = p(date.getSeconds());
  return `${y}${m}${d}${hh}${mm}${ss}`;
}

async function recordEscrow(jobId: string, gateway: string, amountPkr: number, customerId: string, workerId: string) {
  const configSnap = await admin.firestore().collection('configs').doc('fees').get();
  const commissionPct = (configSnap.data()?.commissionPct) ?? 10;
  const commission = Math.round(amountPkr * commissionPct / 100);
  await admin.firestore().collection('payments').doc(jobId).set({
    jobId, gateway, amountPkr,
    commissionPkr: commission,
    netPayoutPkr: amountPkr - commission,
    status: 'escrow',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });
}

export const createStripePaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const { jobId, amountPkr } = data;
  if (!stripeKey) throw new functions.https.HttpsError('failed-precondition', 'Stripe not configured');

  const jobSnap = await admin.firestore().collection('jobs').doc(jobId).get();
  if (!jobSnap.exists) {
    await admin.firestore().collection('jobs').doc(jobId).set({
      id: jobId, customerId: context.auth.uid, workerId: 'demo-worker',
      amount: amountPkr, status: 'requested', createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
  }

  const intent = await stripe.paymentIntents.create({
    amount: toMinorUnitPKR(amountPkr),
    currency: 'pkr',
    automatic_payment_methods: { enabled: true },
    metadata: { jobId, customerId: context.auth.uid },
  });

  await admin.firestore().collection('jobs').doc(jobId).set({
    payment: { intentId: intent.id, amountPkr, status: 'requires_confirmation', gateway: 'stripe' }
  }, { merge: true });

  return { clientSecret: intent.client_secret };
});

export const confirmPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const { jobId, gateway } = data;

  const jobRef = admin.firestore().collection('jobs').doc(jobId);
  const job = (await jobRef.get()).data();
  if (!job) throw new functions.https.HttpsError('not-found', 'Job not found');

  await jobRef.set({ payment: { ...job.payment, status: 'paid', gateway } }, { merge: true });

  const amountPkr = job.payment?.amountPkr ?? job.amount ?? 0;
  await recordEscrow(jobId, gateway, amountPkr, job.customerId, job.workerId);
  return { ok: true };
});

// JazzCash Hosted Checkout
export const createJazzCashCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const { jobId, amountPkr } = data;
  const jc = cfg.jazzcash || {};
  const MERCHANT_ID = jc.merchant_id;
  const PASSWORD = jc.password;
  const SALT = jc.integrity_salt;
  const RETURN_URL = jc.return_url || 'https://fixit.local/return';
  if (!MERCHANT_ID || !PASSWORD || !SALT) throw new functions.https.HttpsError('failed-precondition', 'JazzCash not configured');

  const now = new Date();
  const expiry = new Date(now.getTime() + 60 * 60 * 1000);
  const txnRef = `T${fmtDateTime(now)}${Math.floor(Math.random()*1000)}`;

  const fields: Record<string,string> = {
    pp_Version: '2.0',
    pp_TxnType: 'MWALLET',
    pp_Language: 'EN',
    pp_MerchantID: MERCHANT_ID,
    pp_SubMerchantID: '',
    pp_Password: PASSWORD,
    pp_BankID: '',
    pp_ProductID: '',
    pp_TxnRefNo: txnRef,
    pp_Amount: String(amountPkr * 100),
    pp_TxnCurrency: 'PKR',
    pp_TxnDateTime: fmtDateTime(now),
    pp_BillReference: jobId,
    pp_Description: `Job ${jobId}`,
    pp_ReturnURL: RETURN_URL,
    pp_TxnExpiryDateTime: fmtDateTime(expiry)
  };

  const orderedKeys = Object.keys(fields).sort();
  const hashString = `${SALT}&` + orderedKeys.map(k => fields[k]).join('&');
  const hmac = crypto.createHmac('sha256', SALT).update(hashString).digest('hex').toUpperCase();
  fields['pp_SecureHash'] = hmac;

  await admin.firestore().collection('jobs').doc(jobId).set({
    id: jobId, customerId: context.auth.uid, workerId: 'demo-worker',
    amount: amountPkr, payment: { gateway: 'jazzcash', status: 'initiated' }
  }, { merge: true });

  const postUrl = 'https://sandbox.jazzcash.com.pk/CustomerPortal/transactionmanagement/merchantform/';
  return { postUrl, fields, returnUrl: RETURN_URL };
});

// Easypaisa Hosted Checkout (placeholder; replace with your contract)
export const createEasypaisaCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const { jobId, amountPkr } = data;
  const ep = cfg.easypaisa || {};
  const MERCHANT_ID = ep.merchant_id;
  const PASSWORD = ep.password;
  const RETURN_URL = ep.return_url || 'https://fixit.local/return';
  const SALT = ep.integrity_salt || 'salt';
  if (!MERCHANT_ID || !PASSWORD) throw new functions.https.HttpsError('failed-precondition', 'Easypaisa not configured');

  const now = new Date();
  const orderId = `E${fmtDateTime(now)}${Math.floor(Math.random()*1000)}`;

  const fields: Record<string,string> = {
    merchantId: MERCHANT_ID,
    amount: String(amountPkr),
    orderId,
    description: `Job ${jobId}`,
    returnUrl: RETURN_URL,
    signature: crypto.createHmac('sha256', SALT).update(`${MERCHANT_ID}&${amountPkr}&${orderId}`).digest('hex')
  };

  await admin.firestore().collection('jobs').doc(jobId).set({
    id: jobId, customerId: context.auth.uid, workerId: 'demo-worker',
    amount: amountPkr, payment: { gateway: 'easypaisa', status: 'initiated' }
  }, { merge: true });

  const postUrl = ep.checkout_url || 'https://easypaystg.easypaisa.com.pk/easypay/Index.jsf';
  return { postUrl, fields, returnUrl: RETURN_URL };
});
