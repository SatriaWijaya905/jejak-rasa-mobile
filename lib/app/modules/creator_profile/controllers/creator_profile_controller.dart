import 'package:get/get.dart';

import '../../../services/follow_service.dart';

class CreatorProfileController
    extends GetxController {

  final FollowService _followService =
      FollowService();

  final isFollowing = false.obs;

  final isLoadingFollow = false.obs;

  late String creatorUid;
  late String currentUid;

  CreatorProfileController init({
    required String creatorUid,
    required String currentUid,
  }) {

    this.creatorUid = creatorUid;
    this.currentUid = currentUid;

    checkFollowingStatus();

    return this;
  }

  Future<void> checkFollowingStatus() async {

    final result =
        await _followService.isFollowing(
      currentUid: currentUid,
      creatorUid: creatorUid,
    );

    isFollowing.value = result;
  }

  Future<void> toggleFollow() async {

    try {

      isLoadingFollow.value = true;

      if (isFollowing.value) {

        await _followService.unfollowUser(
          currentUid: currentUid,
          creatorUid: creatorUid,
        );

        isFollowing.value = false;

      } else {

        await _followService.followUser(
          currentUid: currentUid,
          creatorUid: creatorUid,
        );

        isFollowing.value = true;
      }

    } catch (e) {

      Get.snackbar(
        'Error',
        e.toString(),
      );

    } finally {

      isLoadingFollow.value = false;
    }
  }
}