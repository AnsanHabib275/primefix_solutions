import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkerDashboardScreen extends StatelessWidget {
  final WorkerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Obx(
            () => Switch(
              value: controller.isOnline.value,
              onChanged: (value) => controller.toggleOnlineStatus(value),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Obx(
            () => StatusCard(
              isOnline: controller.isOnline.value,
              todayEarnings: controller.todayEarnings.value,
              completedJobs: controller.completedJobs.value,
              rating: controller.rating.value,
            ),
          ),

          // Active Jobs Section
          Expanded(
            child: Obx(() {
              if (controller.activeJobs.isEmpty) {
                return EmptyStateWidget(
                  message: 'No active jobs',
                  subtitle: 'Turn on availability to receive job requests',
                );
              }

              return ListView.builder(
                itemCount: controller.activeJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.activeJobs[index];
                  return JobCard(
                    booking: job,
                    onAccept: () => controller.acceptJob(job.id),
                    onDecline: () => controller.declineJob(job.id),
                    onViewDetails:
                        () => Get.toNamed('/job-details', arguments: job),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/worker-profile-edit'),
        child: Icon(Icons.person),
      ),
    );
  }
}

class WorkerDashboardScreen extends StatelessWidget {
  final WorkerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Obx(
            () => Switch(
              value: controller.isOnline.value,
              onChanged: (value) => controller.toggleOnlineStatus(value),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Obx(
            () => StatusCard(
              isOnline: controller.isOnline.value,
              todayEarnings: controller.todayEarnings.value,
              completedJobs: controller.completedJobs.value,
              rating: controller.rating.value,
            ),
          ),

          // Active Jobs Section
          Expanded(
            child: Obx(() {
              if (controller.activeJobs.isEmpty) {
                return EmptyStateWidget(
                  message: 'No active jobs',
                  subtitle: 'Turn on availability to receive job requests',
                );
              }

              return ListView.builder(
                itemCount: controller.activeJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.activeJobs[index];
                  return JobCard(
                    booking: job,
                    onAccept: () => controller.acceptJob(job.id),
                    onDecline: () => controller.declineJob(job.id),
                    onViewDetails:
                        () => Get.toNamed('/job-details', arguments: job),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/worker-profile-edit'),
        child: Icon(Icons.person),
      ),
    );
  }
}
