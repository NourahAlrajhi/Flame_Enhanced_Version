part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class GetUserLoaded extends UserState {}

class GetDataUserDone extends UserState {}

class DoneSearch extends UserState {}

class SearchLoaded extends UserState {}

class DoneSendRequest extends UserState {}

class LoadedSendRequest extends UserState {}

class GetRequestLoaded extends UserState {}

class GetRequestDone extends UserState {}

class GetDataMyUserLoaded extends UserState {}

class GetDataMyUserDone extends UserState {}

class GetAllRequestLoaded extends UserState {}

class GetAllRequestDone extends UserState {}

class GetAllRequesTalaptDone extends UserState {}

class UpdateRequestCancle extends UserState {}

class UpdateRequestCancleLoaded extends UserState {}

class ChangeCurrentIndex extends UserState {}

class GetAllFrinds extends UserState {}

class GetAllRequestedDone extends UserState {}

class GetAllFrindsRequest extends UserState {}

class Damage extends UserState {}

class RemoveSearch extends UserState {}

class RemoveSearchLoaded extends UserState {}

class SearchConcats extends UserState {}

class AddContacts extends UserState {}

class GetIdFrindes extends UserState {}

class CheckUserLoaded extends UserState {}

class CheckUserError extends UserState {
  final String phone;

  CheckUserError({required this.phone});
}

class AddPhoneNumberListDone extends UserState {}

class UpdateStatusDone extends UserState {}

class UpdateStatusDoneAccept extends UserState {}

class AddLoaded extends UserState {}

class UpdateStatusDoneLoaded extends UserState {}

class UpdateStatusDoneDone extends UserState {}

class AddDone extends UserState {}

class UpdateRR extends UserState {}

class GetNotificationLoaded extends UserState {}

class GetNotificationtDone extends UserState {}

class GetAllFriendsDone extends UserState {}

class GetAllFriendsLoaded extends UserState {}

class GetAllPostLoaded extends UserState {}

class GetAllPostDone extends UserState {}

class NotFoundFriend extends UserState {}

class GetUserFriend extends UserState {}

class GetUserFriendtDone extends UserState {}

class GetUserFriend2 extends UserState {}

class GetUserFriendtDone2 extends UserState {}

class GetAllFriendsLoaded2 extends UserState {}

class GetAllFriendsDone2 extends UserState {}

class GetAllPostLoaded2 extends UserState {}

class GetAllPostDone2 extends UserState {}

class GetAllcategoriesLoaded2 extends UserState {}

class GetAllcategoriesDone2 extends UserState {}

class deleteFrindLoaded extends UserState {}

class deleteFrindDone extends UserState {}

class profilePicUpdate extends UserState {}

class profilePicUpdateDone extends UserState {}

class updatePicFriendsStart extends UserState {}

class updatePicFriendsEnd extends UserState {}

class updateNotifictaionsStart extends UserState {}

class updateNotifictaionsEnd extends UserState {}

class DiaplayNameUpdate extends UserState {}

class DiaplayNameDone extends UserState {}

class updateNotifictaionsNameStart extends UserState {}

class updateNotifictaionsNameEnd extends UserState {}

class updateNameFriendsStart extends UserState {}

class updateNameFriendsEnd extends UserState {}

class updatePostStart extends UserState {}

class updatePostEnd extends UserState {}

class updateRecStart extends UserState {}

class updateRecEnd extends UserState {}

class ViewUserPost extends UserState {}

class ViewUserPostDone extends UserState {}

class ViewUserPostDone2 extends UserState {}

class DELETPOSTLOADED extends UserState {}

class deletePostDone extends UserState {}

class SavePOSTLOADED extends UserState {}

class SavePOSTDone extends UserState {}

class DELETSavedPOSTLOADED extends UserState {}

class deleteSavedPostDone extends UserState {}

class ViewUserSavedPost extends UserState {}

class ViewUserSavedPostDone extends UserState {}

class ViewUserSavedPostDone2 extends UserState {}

class updateSavedPostStart extends UserState {}

class updateSavedPostEnd extends UserState {}

class updateMyPostStart extends UserState {}

class updateMyPostEnd extends UserState {}

class updateStatusStart extends UserState {}

class updateStatusDone extends UserState {}

class updateMyFriendPostStart extends UserState {}

class updateMyFriendPostEnd extends UserState {}

class EditReviewloaded extends UserState {}

class EditReviewdone extends UserState {}

class GetRevload extends UserState {}

class GetRevDone extends UserState {}

class Deletnotificationstart extends UserState {}

class DeletnotificationDone extends UserState {}

class GETUSERRECOMMENDATIONstart extends UserState {}

class GETUSERRECOMMENDATIONstartDone extends UserState {}

class UpdateContatctDone extends UserState {}

class notupdated extends UserState {}

class Updateimg extends UserState {}
