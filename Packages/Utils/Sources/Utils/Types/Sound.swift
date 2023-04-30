#if canImport(AVFoundation)

import AVFoundation

/// Helper for playing system and custom sounds.
///
/// Contains `SystemSound` enum with many built in sounds.
/// Usage example:
///
///     let sound = Sound()
///
///     sound.play(.uisounds_swish)
///
///     let path = Bundle.main.path(forResource: "beep", ofType: "wav")
///     sound.play(fromPath: path)
///
public final class Sound {

    public init() {}

    // MARK: AudioToolbox

    public func play(_ systemSound: SystemSound) {
        play(fromPath: systemSound.rawValue)
    }

    public func play(fromPath path: String) {
        #if !targetEnvironment(simulator) && !os(watchOS)
        var id: SystemSoundID = 0
        let url = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(url as CFURL, &id)
        play(soundID: id)
        #endif
    }

    public func play(soundID: UInt32) {
        #if !targetEnvironment(simulator) && !os(watchOS)
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { id, _ in AudioServicesDisposeSystemSoundID(id) }, nil)
        AudioServicesPlaySystemSound(soundID)
        #endif
    }

    // MARK: AVFoundation

    private var players = [String: AVAudioPlayer]()

    @discardableResult
    public func prepareSound(atPath path: String) -> AVAudioPlayer? {
        let url = URL(fileURLWithPath: path)
        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        players[path] = player
        return player
    }

    public func playSound(atPath path: String) {
        if let player = players[path] {
            player.play()
        } else {
            prepareSound(atPath: path)?.play()
        }
    }

    public func cleanupSound(atPath path: String) {
        players[path] = nil
    }

}

// swiftlint:disable line_length
// swiftformat:disable wrap
public enum SystemSound: String {
    case modern_camera_shutter_burst_begin = "/System/Library/Audio/UISounds/Modern/camera_shutter_burst_begin.caf"
    case modern_camera_shutter_burst_end = "/System/Library/Audio/UISounds/Modern/camera_shutter_burst_end.caf"
    case modern_camera_shutter_burst = "/System/Library/Audio/UISounds/Modern/camera_shutter_burst.caf"
    case nano_3rd_party_critical_haptic = "/System/Library/Audio/UISounds/nano/3rd_Party_Critical_Haptic.caf"
    case nano_3rdparty_directiondown_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_DirectionDown_Haptic.caf"
    case nano_3rdparty_directionup_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_DirectionUp_Haptic.caf"
    case nano_3rdparty_failure_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_Failure_Haptic.caf"
    case nano_3rdparty_retry_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_Retry_Haptic.caf"
    case nano_3rdparty_start_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_Start_Haptic.caf"
    case nano_3rdparty_stop_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_Stop_Haptic.caf"
    case nano_3rdparty_success_haptic = "/System/Library/Audio/UISounds/nano/3rdParty_Success_Haptic.caf"
    case nano_accessscancomplete_haptic = "/System/Library/Audio/UISounds/nano/AccessScanComplete_Haptic.caf"
    case nano_alarm_haptic = "/System/Library/Audio/UISounds/nano/Alarm_Haptic.caf"
    case nano_alarm_nightstand_haptic = "/System/Library/Audio/UISounds/nano/Alarm_Nightstand_Haptic.caf"
    case nano_alert_1stparty_haptic = "/System/Library/Audio/UISounds/nano/Alert_1stParty_Haptic.caf"
    case nano_alert_3rdparty_haptic = "/System/Library/Audio/UISounds/nano/Alert_3rdParty_Haptic.caf"
    case nano_alert_3rdparty_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_3rdParty_Salient_Haptic.caf"
    case nano_alert_activityfriendsgoalattained_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityFriendsGoalAttained_Haptic.caf"
    case nano_alert_activitygoalattained_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityGoalAttained_Haptic.caf"
    case nano_alert_activitygoalattained_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityGoalAttained_Salient_Haptic.caf"
    case nano_alert_activitygoalbehind_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityGoalBehind_Haptic.caf"
    case nano_alert_activitygoalbehind_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityGoalBehind_Salient_Haptic.caf"
    case nano_alert_activitygoalclose_haptic = "/System/Library/Audio/UISounds/nano/Alert_ActivityGoalClose_Haptic.caf"
    case nano_alert_batterylow_10p_haptic = "/System/Library/Audio/UISounds/nano/Alert_BatteryLow_10p_Haptic.caf"
    case nano_alert_batterylow_5p_haptic = "/System/Library/Audio/UISounds/nano/Alert_BatteryLow_5p_Haptic.caf"
    case nano_alert_batterylow_5p_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_BatteryLow_5p_Salient_Haptic.caf"
    case nano_alert_calendar_haptic = "/System/Library/Audio/UISounds/nano/Alert_Calendar_Haptic.caf"
    case nano_alert_calendar_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_Calendar_Salient_Haptic.caf"
    case nano_alert_health_haptic = "/System/Library/Audio/UISounds/nano/Alert_Health_Haptic.caf"
    case nano_alert_mapsdirectionsinapp_haptic = "/System/Library/Audio/UISounds/nano/Alert_MapsDirectionsInApp_Haptic.caf"
    case nano_alert_passbookbalance_haptic = "/System/Library/Audio/UISounds/nano/Alert_PassbookBalance_Haptic.caf"
    case nano_alert_passbookgeofence_haptic = "/System/Library/Audio/UISounds/nano/Alert_PassbookGeofence_Haptic.caf"
    case nano_alert_passbookgeofence_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_PassbookGeofence_Salient_Haptic.caf"
    case nano_alert_photostreamactivity_haptic = "/System/Library/Audio/UISounds/nano/Alert_PhotostreamActivity_Haptic.caf"
    case nano_alert_reminderdue_haptic = "/System/Library/Audio/UISounds/nano/Alert_ReminderDue_Haptic.caf"
    case nano_alert_reminderdue_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_ReminderDue_Salient_Haptic.caf"
    case nano_alert_spartanconnected_lowlatency_haptic = "/System/Library/Audio/UISounds/nano/Alert_SpartanConnected_LowLatency_Haptic.caf"
    case nano_alert_spartanconnecting_haptic = "/System/Library/Audio/UISounds/nano/Alert_SpartanConnecting_Haptic.caf"
    case nano_alert_spartanconnecting_lowlatency_haptic = "/System/Library/Audio/UISounds/nano/Alert_SpartanConnecting_LowLatency_Haptic.caf"
    case nano_alert_spartandisconnected_lowlatency_haptic = "/System/Library/Audio/UISounds/nano/Alert_SpartanDisconnected_LowLatency_Haptic.caf"
    case nano_alert_voicemail_haptic = "/System/Library/Audio/UISounds/nano/Alert_Voicemail_Haptic.caf"
    case nano_alert_voicemail_salient_haptic = "/System/Library/Audio/UISounds/nano/Alert_Voicemail_Salient_Haptic.caf"
    case nano_alert_walkietalkie_haptic = "/System/Library/Audio/UISounds/nano/Alert_WalkieTalkie_Haptic.caf"
    case nano_autounlock_haptic = "/System/Library/Audio/UISounds/nano/AutoUnlock_Haptic.caf"
    case nano_batterymagsafe_haptic = "/System/Library/Audio/UISounds/nano/BatteryMagsafe_Haptic.caf"
    case nano_beat_haptic = "/System/Library/Audio/UISounds/nano/Beat_Haptic.caf"
    case nano_buddymigrationstart_haptic = "/System/Library/Audio/UISounds/nano/BuddyMigrationStart_Haptic.caf"
    case nano_buddypairingfailure_haptic = "/System/Library/Audio/UISounds/nano/BuddyPairingFailure_Haptic.caf"
    case nano_buddypairingremoteconnection_haptic = "/System/Library/Audio/UISounds/nano/BuddyPairingRemoteConnection_Haptic.caf"
    case nano_buddypairingremotetap_haptic = "/System/Library/Audio/UISounds/nano/BuddyPairingRemoteTap_Haptic.caf"
    case nano_buddypairingsuccess_haptic = "/System/Library/Audio/UISounds/nano/BuddyPairingSuccess_Haptic.caf"
    case nano_busy_tone_ansi = "/System/Library/Audio/UISounds/nano/busy_tone_ansi.caf"
    case nano_busy_tone_cept = "/System/Library/Audio/UISounds/nano/busy_tone_cept.caf"
    case nano_call_waiting_tone_ansi = "/System/Library/Audio/UISounds/nano/call_waiting_tone_ansi.caf"
    case nano_call_waiting_tone_cept = "/System/Library/Audio/UISounds/nano/call_waiting_tone_cept.caf"
    case nano_cameracountdownimminent_haptic = "/System/Library/Audio/UISounds/nano/CameraCountdownImminent_Haptic.caf"
    case nano_cameracountdowntick_haptic = "/System/Library/Audio/UISounds/nano/CameraCountdownTick_Haptic.caf"
    case nano_camerashutter_haptic = "/System/Library/Audio/UISounds/nano/CameraShutter_Haptic.caf"
    case nano_ct_call_waiting = "/System/Library/Audio/UISounds/nano/ct-call-waiting.caf"
    case nano_detent_haptic = "/System/Library/Audio/UISounds/nano/Detent_Haptic.caf"
    case nano_donotdisturb_haptic = "/System/Library/Audio/UISounds/nano/DoNotDisturb_Haptic.caf"
    case nano_dtmf_0 = "/System/Library/Audio/UISounds/nano/dtmf-0.caf"
    case nano_dtmf_1 = "/System/Library/Audio/UISounds/nano/dtmf-1.caf"
    case nano_dtmf_2 = "/System/Library/Audio/UISounds/nano/dtmf-2.caf"
    case nano_dtmf_3 = "/System/Library/Audio/UISounds/nano/dtmf-3.caf"
    case nano_dtmf_4 = "/System/Library/Audio/UISounds/nano/dtmf-4.caf"
    case nano_dtmf_5 = "/System/Library/Audio/UISounds/nano/dtmf-5.caf"
    case nano_dtmf_6 = "/System/Library/Audio/UISounds/nano/dtmf-6.caf"
    case nano_dtmf_7 = "/System/Library/Audio/UISounds/nano/dtmf-7.caf"
    case nano_dtmf_8 = "/System/Library/Audio/UISounds/nano/dtmf-8.caf"
    case nano_dtmf_9 = "/System/Library/Audio/UISounds/nano/dtmf-9.caf"
    case nano_dtmf_pound = "/System/Library/Audio/UISounds/nano/dtmf-pound.caf"
    case nano_dtmf_star = "/System/Library/Audio/UISounds/nano/dtmf-star.caf"
    case nano_end_call_tone_cept = "/System/Library/Audio/UISounds/nano/end_call_tone_cept.caf"
    case nano_et_beginnotification_haptic = "/System/Library/Audio/UISounds/nano/ET_BeginNotification_Haptic.caf"
    case nano_et_beginnotification_salient_haptic = "/System/Library/Audio/UISounds/nano/ET_BeginNotification_Salient_Haptic.caf"
    case nano_et_remotetap_receive_haptic = "/System/Library/Audio/UISounds/nano/ET_RemoteTap_Receive_Haptic.caf"
    case nano_et_remotetap_send_haptic = "/System/Library/Audio/UISounds/nano/ET_RemoteTap_Send_Haptic.caf"
    case nano_gotosleep_haptic = "/System/Library/Audio/UISounds/nano/GoToSleep_Haptic.caf"
    case nano_headphoneaudioexposurelimitexceeded = "/System/Library/Audio/UISounds/nano/HeadphoneAudioExposureLimitExceeded.caf"
    case nano_healthnotificationurgent = "/System/Library/Audio/UISounds/nano/HealthNotificationUrgent.caf"
    case nano_healthreadingcomplete_haptic = "/System/Library/Audio/UISounds/nano/HealthReadingComplete_Haptic.caf"
    case nano_healthreadingfail_haptic = "/System/Library/Audio/UISounds/nano/HealthReadingFail_Haptic.caf"
    case nano_hourlychime_haptic = "/System/Library/Audio/UISounds/nano/HourlyChime_Haptic.caf"
    case nano_hummingbirdcompletion_haptic = "/System/Library/Audio/UISounds/nano/HummingbirdCompletion_Haptic.caf"
    case nano_hummingbirdnotification_haptic = "/System/Library/Audio/UISounds/nano/HummingbirdNotification_Haptic.caf"
    case nano_jbl_begin = "/System/Library/Audio/UISounds/nano/jbl_begin.caf"
    case nano_jbl_cancel = "/System/Library/Audio/UISounds/nano/jbl_cancel.caf"
    case nano_jbl_confirm = "/System/Library/Audio/UISounds/nano/jbl_confirm.caf"
    case nano_messagesincoming_haptic = "/System/Library/Audio/UISounds/nano/MessagesIncoming_Haptic.caf"
    case nano_messagesoutgoing_haptic = "/System/Library/Audio/UISounds/nano/MessagesOutgoing_Haptic.caf"
    case nano_multiwayinvitation = "/System/Library/Audio/UISounds/nano/MultiwayInvitation.caf"
    case nano_multiwayjoin = "/System/Library/Audio/UISounds/nano/MultiwayJoin.caf"
    case nano_multiwayleave = "/System/Library/Audio/UISounds/nano/MultiwayLeave.caf"
    case nano_navigationgenericmaneuver_haptic = "/System/Library/Audio/UISounds/nano/NavigationGenericManeuver_Haptic.caf"
    case nano_navigationgenericmaneuver_salient_haptic = "/System/Library/Audio/UISounds/nano/NavigationGenericManeuver_Salient_Haptic.caf"
    case nano_navigationleftturn_haptic = "/System/Library/Audio/UISounds/nano/NavigationLeftTurn_Haptic.caf"
    case nano_navigationleftturn_salient_haptic = "/System/Library/Audio/UISounds/nano/NavigationLeftTurn_Salient_Haptic.caf"
    case nano_navigationrightturn_haptic = "/System/Library/Audio/UISounds/nano/NavigationRightTurn_Haptic.caf"
    case nano_navigationrightturn_salient_haptic = "/System/Library/Audio/UISounds/nano/NavigationRightTurn_Salient_Haptic.caf"
    case nano_notification_haptic = "/System/Library/Audio/UISounds/nano/Notification_Haptic.caf"
    case nano_notification_salient_haptic = "/System/Library/Audio/UISounds/nano/Notification_Salient_Haptic.caf"
    case nano_onoffpasscodefailure_haptic = "/System/Library/Audio/UISounds/nano/OnOffPasscodeFailure_Haptic.caf"
    case nano_onoffpasscodeunlock_haptic = "/System/Library/Audio/UISounds/nano/OnOffPasscodeUnlock_Haptic.caf"
    case nano_onoffpasscodeunlockcampanion_haptic = "/System/Library/Audio/UISounds/nano/OnOffPasscodeUnlockCampanion_Haptic.caf"
    case nano_orbexit_haptic = "/System/Library/Audio/UISounds/nano/OrbExit_Haptic.caf"
    case nano_orblayers_haptic = "/System/Library/Audio/UISounds/nano/OrbLayers_Haptic.caf"
    case nano_phoneanswer_haptic = "/System/Library/Audio/UISounds/nano/PhoneAnswer_Haptic.caf"
    case nano_phonehangup_haptic = "/System/Library/Audio/UISounds/nano/PhoneHangUp_Haptic.caf"
    case nano_phonehold_haptic = "/System/Library/Audio/UISounds/nano/PhoneHold_Haptic.caf"
    case nano_photoszoomdetent_haptic = "/System/Library/Audio/UISounds/nano/PhotosZoomDetent_Haptic.caf"
    case nano_preview_audioandhaptic = "/System/Library/Audio/UISounds/nano/Preview_AudioAndHaptic.caf"
    case nano_qb_dictation_haptic = "/System/Library/Audio/UISounds/nano/QB_Dictation_Haptic.caf"
    case nano_qb_dictation_off_haptic = "/System/Library/Audio/UISounds/nano/QB_Dictation_Off_Haptic.caf"
    case nano_remotecamerashutterburstbegin_haptic = "/System/Library/Audio/UISounds/nano/RemoteCameraShutterBurstBegin_Haptic.caf"
    case nano_remotecamerashutterburstend_haptic = "/System/Library/Audio/UISounds/nano/RemoteCameraShutterBurstEnd_Haptic.caf"
    case nano_ringback_tone_ansi = "/System/Library/Audio/UISounds/nano/ringback_tone_ansi.caf"
    case nano_ringback_tone_aus = "/System/Library/Audio/UISounds/nano/ringback_tone_aus.caf"
    case nano_ringback_tone_cept = "/System/Library/Audio/UISounds/nano/ringback_tone_cept.caf"
    case nano_ringback_tone_hk = "/System/Library/Audio/UISounds/nano/ringback_tone_hk.caf"
    case nano_ringback_tone_uk = "/System/Library/Audio/UISounds/nano/ringback_tone_uk.caf"
    case nano_ringtone_2_ducked_haptic_sashimi = "/System/Library/Audio/UISounds/nano/Ringtone_2_Ducked_Haptic-sashimi.caf"
    case nano_ringtone_2_haptic_sashimi = "/System/Library/Audio/UISounds/nano/Ringtone_2_Haptic-sashimi.caf"
    case nano_ringtone_uk_haptic = "/System/Library/Audio/UISounds/nano/Ringtone_UK_Haptic.caf"
    case nano_ringtone_us_haptic = "/System/Library/Audio/UISounds/nano/Ringtone_US_Haptic.caf"
    case nano_ringtoneducked_uk_haptic = "/System/Library/Audio/UISounds/nano/RingtoneDucked_UK_Haptic.caf"
    case nano_ringtoneducked_us_haptic = "/System/Library/Audio/UISounds/nano/RingtoneDucked_US_Haptic.caf"
    case nano_salientnotification_haptic = "/System/Library/Audio/UISounds/nano/SalientNotification_Haptic.caf"
    case nano_screencapture = "/System/Library/Audio/UISounds/nano/ScreenCapture.caf"
    case nano_sedentarytimer_haptic = "/System/Library/Audio/UISounds/nano/SedentaryTimer_Haptic.caf"
    case nano_sedentarytimer_salient_haptic = "/System/Library/Audio/UISounds/nano/SedentaryTimer_Salient_Haptic.caf"
    case nano_siriautosend_haptic = "/System/Library/Audio/UISounds/nano/SiriAutoSend_Haptic.caf"
    case nano_siristart_haptic = "/System/Library/Audio/UISounds/nano/SiriStart_Haptic.caf"
    case nano_siristopfailure_haptic = "/System/Library/Audio/UISounds/nano/SiriStopFailure_Haptic.caf"
    case nano_siristopsuccess_haptic = "/System/Library/Audio/UISounds/nano/SiriStopSuccess_Haptic.caf"
    case nano_sms_received1 = "/System/Library/Audio/UISounds/nano/sms-received1.caf"
    case nano_sosemergencycontacttextprompt_haptic = "/System/Library/Audio/UISounds/nano/SOSEmergencyContactTextPrompt_Haptic.caf"
    case nano_sosfalldetectionprompt_haptic = "/System/Library/Audio/UISounds/nano/SOSFallDetectionPrompt_Haptic.caf"
    case nano_sosfalldetectionpromptescalation_haptic = "/System/Library/Audio/UISounds/nano/SOSFallDetectionPromptEscalation_Haptic.caf"
    case nano_stockholm_haptic = "/System/Library/Audio/UISounds/nano/Stockholm_Haptic.caf"
    case nano_stockholmactive_haptic = "/System/Library/Audio/UISounds/nano/StockholmActive_Haptic.caf"
    case nano_stockholmactivesinglecycle_haptic = "/System/Library/Audio/UISounds/nano/StockholmActiveSingleCycle_Haptic.caf"
    case nano_stockholmfailure_haptic = "/System/Library/Audio/UISounds/nano/StockholmFailure_Haptic.caf"
    case nano_stopwatchlap_haptic = "/System/Library/Audio/UISounds/nano/StopwatchLap_Haptic.caf"
    case nano_stopwatchreset_haptic = "/System/Library/Audio/UISounds/nano/StopwatchReset_Haptic.caf"
    case nano_stopwatchstart_haptic = "/System/Library/Audio/UISounds/nano/StopwatchStart_Haptic.caf"
    case nano_stopwatchstop_haptic = "/System/Library/Audio/UISounds/nano/StopwatchStop_Haptic.caf"
    case nano_swtest1_haptic = "/System/Library/Audio/UISounds/nano/SwTest1_Haptic.caf"
    case nano_system_notification_haptic = "/System/Library/Audio/UISounds/nano/System_Notification_Haptic.caf"
    case nano_systemstartup_haptic = "/System/Library/Audio/UISounds/nano/SystemStartup_Haptic.caf"
    case nano_timer_haptic = "/System/Library/Audio/UISounds/nano/Timer_Haptic.caf"
    case nano_timercancel_haptic = "/System/Library/Audio/UISounds/nano/TimerCancel_Haptic.caf"
    case nano_timerpause_haptic = "/System/Library/Audio/UISounds/nano/TimerPause_Haptic.caf"
    case nano_timerstart_haptic = "/System/Library/Audio/UISounds/nano/TimerStart_Haptic.caf"
    case nano_timerwheelhoursdetent_haptic = "/System/Library/Audio/UISounds/nano/TimerWheelHoursDetent_Haptic.caf"
    case nano_timerwheelminutesdetent_haptic = "/System/Library/Audio/UISounds/nano/TimerWheelMinutesDetent_Haptic.caf"
    case nano_uiswipe_haptic = "/System/Library/Audio/UISounds/nano/UISwipe_Haptic.caf"
    case nano_uiswitch_off_haptic = "/System/Library/Audio/UISounds/nano/UISwitch_Off_Haptic.caf"
    case nano_uiswitch_on_haptic = "/System/Library/Audio/UISounds/nano/UISwitch_On_Haptic.caf"
    case nano_vc_ended = "/System/Library/Audio/UISounds/nano/vc~ended.caf"
    case nano_vc_invitation_accepted = "/System/Library/Audio/UISounds/nano/vc~invitation-accepted.caf"
    case nano_vc_ringing_watch = "/System/Library/Audio/UISounds/nano/vc~ringing_watch.caf"
    case nano_vc_ringing = "/System/Library/Audio/UISounds/nano/vc~ringing.caf"
    case nano_voiceover_click_haptic = "/System/Library/Audio/UISounds/nano/VoiceOver_Click_Haptic.caf"
    case nano_walkietalkieactiveend_haptic = "/System/Library/Audio/UISounds/nano/WalkieTalkieActiveEnd_Haptic.caf"
    case nano_walkietalkieactivestart_haptic = "/System/Library/Audio/UISounds/nano/WalkieTalkieActiveStart_Haptic.caf"
    case nano_walkietalkiereceiveend_haptic = "/System/Library/Audio/UISounds/nano/WalkieTalkieReceiveEnd_Haptic.caf"
    case nano_walkietalkiereceivestart_haptic = "/System/Library/Audio/UISounds/nano/WalkieTalkieReceiveStart_Haptic.caf"
    case nano_warsaw_haptic = "/System/Library/Audio/UISounds/nano/Warsaw_Haptic.caf"
    case nano_workoutcomplete_haptic = "/System/Library/Audio/UISounds/nano/WorkoutComplete_Haptic.caf"
    case nano_workoutcompleteautodetect = "/System/Library/Audio/UISounds/nano/WorkoutCompleteAutodetect.caf"
    case nano_workoutcountdown_haptic = "/System/Library/Audio/UISounds/nano/WorkoutCountdown_Haptic.caf"
    case nano_workoutpaceabove = "/System/Library/Audio/UISounds/nano/WorkoutPaceAbove.caf"
    case nano_workoutpacebelow = "/System/Library/Audio/UISounds/nano/WorkoutPaceBelow.caf"
    case nano_workoutpaused_haptic = "/System/Library/Audio/UISounds/nano/WorkoutPaused_Haptic.caf"
    case nano_workoutpausedautodetect = "/System/Library/Audio/UISounds/nano/WorkoutPausedAutoDetect.caf"
    case nano_workoutpressstart_haptic = "/System/Library/Audio/UISounds/nano/WorkoutPressStart_Haptic.caf"
    case nano_workoutresumed_haptic = "/System/Library/Audio/UISounds/nano/WorkoutResumed_Haptic.caf"
    case nano_workoutresumedautodetect = "/System/Library/Audio/UISounds/nano/WorkoutResumedAutoDetect.caf"
    case nano_workoutsaved_haptic = "/System/Library/Audio/UISounds/nano/WorkoutSaved_Haptic.caf"
    case nano_workoutselect_haptic = "/System/Library/Audio/UISounds/nano/WorkoutSelect_Haptic.caf"
    case nano_workoutstartautodetect = "/System/Library/Audio/UISounds/nano/WorkoutStartAutodetect.caf"
    case new_anticipate = "/System/Library/Audio/UISounds/New/Anticipate.caf"
    case new_bloom = "/System/Library/Audio/UISounds/New/Bloom.caf"
    case new_calypso = "/System/Library/Audio/UISounds/New/Calypso.caf"
    case new_choo_choo = "/System/Library/Audio/UISounds/New/Choo_Choo.caf"
    case new_descent = "/System/Library/Audio/UISounds/New/Descent.caf"
    case new_fanfare = "/System/Library/Audio/UISounds/New/Fanfare.caf"
    case new_ladder = "/System/Library/Audio/UISounds/New/Ladder.caf"
    case new_minuet = "/System/Library/Audio/UISounds/New/Minuet.caf"
    case new_news_flash = "/System/Library/Audio/UISounds/New/News_Flash.caf"
    case new_noir = "/System/Library/Audio/UISounds/New/Noir.caf"
    case new_sherwood_forest = "/System/Library/Audio/UISounds/New/Sherwood_Forest.caf"
    case new_spell = "/System/Library/Audio/UISounds/New/Spell.caf"
    case new_suspense = "/System/Library/Audio/UISounds/New/Suspense.caf"
    case new_telegraph = "/System/Library/Audio/UISounds/New/Telegraph.caf"
    case new_tiptoes = "/System/Library/Audio/UISounds/New/Tiptoes.caf"
    case new_typewriters = "/System/Library/Audio/UISounds/New/Typewriters.caf"
    case new_update = "/System/Library/Audio/UISounds/New/Update.caf"
    case uisounds_3rd_party_critical = "/System/Library/Audio/UISounds/3rd_party_critical.caf"
    case uisounds_access_scan_complete = "/System/Library/Audio/UISounds/access_scan_complete.caf"
    case uisounds_acknowledgment_received = "/System/Library/Audio/UISounds/acknowledgment_received.caf"
    case uisounds_acknowledgment_sent = "/System/Library/Audio/UISounds/acknowledgment_sent.caf"
    case uisounds_alarm = "/System/Library/Audio/UISounds/alarm.caf"
    case uisounds_begin_record = "/System/Library/Audio/UISounds/begin_record.caf"
    case uisounds_camera_timer_countdown = "/System/Library/Audio/UISounds/camera_timer_countdown.caf"
    case uisounds_camera_timer_final_second = "/System/Library/Audio/UISounds/camera_timer_final_second.caf"
    case uisounds_connect_power = "/System/Library/Audio/UISounds/connect_power.caf"
    case uisounds_ct_busy = "/System/Library/Audio/UISounds/ct-busy.caf"
    case uisounds_ct_congestion = "/System/Library/Audio/UISounds/ct-congestion.caf"
    case uisounds_ct_error = "/System/Library/Audio/UISounds/ct-error.caf"
    case uisounds_ct_keytone2 = "/System/Library/Audio/UISounds/ct-keytone2.caf"
    case uisounds_ct_path_ack = "/System/Library/Audio/UISounds/ct-path-ack.caf"
    case uisounds_end_record = "/System/Library/Audio/UISounds/end_record.caf"
    case uisounds_focus_change_app_icon = "/System/Library/Audio/UISounds/focus_change_app_icon.caf"
    case uisounds_focus_change_keyboard = "/System/Library/Audio/UISounds/focus_change_keyboard.caf"
    case uisounds_focus_change_large = "/System/Library/Audio/UISounds/focus_change_large.caf"
    case uisounds_focus_change_small = "/System/Library/Audio/UISounds/focus_change_small.caf"
    case uisounds_go_to_sleep_alert = "/System/Library/Audio/UISounds/go_to_sleep_alert.caf"
    case uisounds_health_notification = "/System/Library/Audio/UISounds/health_notification.caf"
    case uisounds_jbl_ambiguous = "/System/Library/Audio/UISounds/jbl_ambiguous.caf"
    case uisounds_jbl_begin = "/System/Library/Audio/UISounds/jbl_begin.caf"
    case uisounds_jbl_cancel = "/System/Library/Audio/UISounds/jbl_cancel.caf"
    case uisounds_jbl_confirm = "/System/Library/Audio/UISounds/jbl_confirm.caf"
    case uisounds_jbl_no_match = "/System/Library/Audio/UISounds/jbl_no_match.caf"
    case uisounds_key_press_click = "/System/Library/Audio/UISounds/key_press_click.caf"
    case uisounds_key_press_delete = "/System/Library/Audio/UISounds/key_press_delete.caf"
    case uisounds_key_press_modifier = "/System/Library/Audio/UISounds/key_press_modifier.caf"
    case uisounds_keyboard_press_clear = "/System/Library/Audio/UISounds/keyboard_press_clear.caf"
    case uisounds_keyboard_press_delete = "/System/Library/Audio/UISounds/keyboard_press_delete.caf"
    case uisounds_keyboard_press_normal = "/System/Library/Audio/UISounds/keyboard_press_normal.caf"
    case uisounds_lock = "/System/Library/Audio/UISounds/lock.caf"
    case uisounds_long_low_short_high = "/System/Library/Audio/UISounds/long_low_short_high.caf"
    case uisounds_low_power = "/System/Library/Audio/UISounds/low_power.caf"
    case uisounds_mail_sent = "/System/Library/Audio/UISounds/mail-sent.caf"
    case uisounds_middle_9_short_double_low = "/System/Library/Audio/UISounds/middle_9_short_double_low.caf"
    case uisounds_multiway_invitation = "/System/Library/Audio/UISounds/multiway_invitation.caf"
    case uisounds_navigation_pop = "/System/Library/Audio/UISounds/navigation_pop.caf"
    case uisounds_navigation_push = "/System/Library/Audio/UISounds/navigation_push.caf"
    case uisounds_new_mail = "/System/Library/Audio/UISounds/new-mail.caf"
    case uisounds_nfc_scan_complete = "/System/Library/Audio/UISounds/nfc_scan_complete.caf"
    case uisounds_nfc_scan_failure = "/System/Library/Audio/UISounds/nfc_scan_failure.caf"
    case uisounds_payment_failure = "/System/Library/Audio/UISounds/payment_failure.caf"
    case uisounds_payment_success = "/System/Library/Audio/UISounds/payment_success.caf"
    case uisounds_photoshutter = "/System/Library/Audio/UISounds/photoShutter.caf"
    case uisounds_receivedmessage = "/System/Library/Audio/UISounds/ReceivedMessage.caf"
    case uisounds_ringerchanged = "/System/Library/Audio/UISounds/RingerChanged.caf"
    case uisounds_sentmessage = "/System/Library/Audio/UISounds/SentMessage.caf"
    case uisounds_shake = "/System/Library/Audio/UISounds/shake.caf"
    case uisounds_short_double_high = "/System/Library/Audio/UISounds/short_double_high.caf"
    case uisounds_short_double_low = "/System/Library/Audio/UISounds/short_double_low.caf"
    case uisounds_short_low_high = "/System/Library/Audio/UISounds/short_low_high.caf"
    case uisounds_simtoolkitcalldropped = "/System/Library/Audio/UISounds/SIMToolkitCallDropped.caf"
    case uisounds_simtoolkitgeneralbeep = "/System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf"
    case uisounds_simtoolkitnegativeack = "/System/Library/Audio/UISounds/SIMToolkitNegativeACK.caf"
    case uisounds_simtoolkitpositiveack = "/System/Library/Audio/UISounds/SIMToolkitPositiveACK.caf"
    case uisounds_simtoolkitsms = "/System/Library/Audio/UISounds/SIMToolkitSMS.caf"
    case uisounds_sms_received1 = "/System/Library/Audio/UISounds/sms-received1.caf"
    case uisounds_sms_received2 = "/System/Library/Audio/UISounds/sms-received2.caf"
    case uisounds_sms_received3 = "/System/Library/Audio/UISounds/sms-received3.caf"
    case uisounds_sms_received4 = "/System/Library/Audio/UISounds/sms-received4.caf"
    case uisounds_sms_received5 = "/System/Library/Audio/UISounds/sms-received5.caf"
    case uisounds_sms_received6 = "/System/Library/Audio/UISounds/sms-received6.caf"
    case uisounds_swish = "/System/Library/Audio/UISounds/Swish.caf"
    case uisounds_tink = "/System/Library/Audio/UISounds/Tink.caf"
    case uisounds_tock = "/System/Library/Audio/UISounds/Tock.caf"
    case uisounds_tweet_sent = "/System/Library/Audio/UISounds/tweet_sent.caf"
    case uisounds_ussd = "/System/Library/Audio/UISounds/ussd.caf"
    case uisounds_warsaw = "/System/Library/Audio/UISounds/warsaw.caf"
    case uisounds_wheels_of_time = "/System/Library/Audio/UISounds/wheels_of_time.caf"
}
// swiftlint:enable line_length
// swiftformat:enable wrap

#endif
