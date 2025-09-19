import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/location_controller.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Obx(
          () => Text(
            LocationController.to.currentPosition.value?.address ??
                'Loading...',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/notifications'),
            icon: Badge(
              count: NotificationController.to.unreadCount.value,
              child: Icon(Icons.notifications),
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/chat-list'),
            icon: Icon(Icons.chat),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              hintText: 'What service do you need?',
              onSubmitted: (query) {
                Get.toNamed('/search-results', arguments: query);
              },
            ),
          ),

          // Quick Categories
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ServiceCategories.all.length,
              itemBuilder: (context, index) {
                final category = ServiceCategories.all[index];
                return CategoryCard(
                  category: category,
                  onTap: () => Get.toNamed('/category', arguments: category),
                );
              },
            ),
          ),

          // Featured Workers
          Expanded(
            child: Obx(() {
              if (LocationController.to.nearbyWorkers.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: LocationController.to.nearbyWorkers.length,
                itemBuilder: (context, index) {
                  final worker = LocationController.to.nearbyWorkers[index];
                  return WorkerCard(
                    worker: worker,
                    onTap:
                        () => Get.toNamed(
                          '/worker-profile',
                          arguments: worker.id,
                        ),
                    onBookNow: () => _quickBook(worker),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _quickBook(Worker worker) {
    Get.bottomSheet(
      QuickBookingSheet(worker: worker),
      isScrollControlled: true,
    );
  }
}
