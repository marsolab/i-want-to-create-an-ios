# App Review notes — draft for the validated release

Use this text only after the release/device gates in README pass. Fill the published privacy-policy URL and support contact in App Store Connect.

SalahSide is an English-language iPhone prayer app. It does not require a user account or a login. On first launch, select a supported city and calculation method, adjust optional focus/notification settings and tap Continue to membership.

Monthly and yearly auto-renewable subscriptions belong to one subscription group. Eligible Apple Accounts receive a three-day introductory free trial; the app uses Apple's actual eligibility and localized StoreKit metadata. Setup itself does not begin the trial or grant membership. Review purchase/restore using Apple's review purchase environment; no custom password or hidden unlock code is provided.

Screen Time is optional. After authorization for individual use, choose distracting apps in Apple's picker. At enabled prayer windows those selected targets are shielded. On iOS 26.5 and later the shield button opens SalahSide through Apple's supported API. Earlier versions explain how to open SalahSide manually. Start/finish, Already prayed, Unlock for this prayer and Pause for one hour are available inside SalahSide. Unlock does not create a prayer completion record. Denied/revoked permission, unavailable scheduling or expired saved membership clears app-owned restrictions.

Times are calculated locally for London, New York, Toronto, Dubai and Kuala Lumpur. Method, Asr convention, high-latitude rule and minute adjustments are user configurable. Prayer records are voluntary self-reports, not verification of worship. No account, advertising or behavioral analytics service is used.

Daily affirmations are accessible from Settings. Widgets support small/medium Home Screen and rectangular Lock Screen families and use the verified subscription snapshot; missing or expired membership displays an invitation to open SalahSide.

App identity: com.marsolab.PrayerFocus. Extensions: .Widgets, .Monitor, .Shield and .ShieldAction. The App Group is group.com.marsolab.PrayerFocus. The public name is SalahSide; technical identities were retained during renaming.
