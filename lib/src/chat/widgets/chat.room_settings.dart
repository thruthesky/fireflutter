/// They might be cases that you want to have your chat room to be restricted to only
/// user that have verified only can interact or restricted by gender you can
/// add ChatRoomSetting() in the ChatService.instance.init(chatRoomSettings)
///
///
class ChatRoomSettings {
  final bool enableVerifiedUserOption;
  final bool enableGenderOption;
  final String? domain;

  /// [enableVerifiedUserOption] enable verifeid user option
  ///
  /// [enableGenderOption] enable gender user option
  const ChatRoomSettings(
      {this.enableVerifiedUserOption = true,
      this.enableGenderOption = true,
      this.domain});
}
