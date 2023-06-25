local FBInAppEvents = {
	AppEventName = {
		AchievedLevel = "fb_mobile_level_achieved",
		ActivatedApp = "fb_mobile_activate_app",
		AddedPaymentInfo = "fb_mobile_add_payment_info",
		AddedToCart = "fb_mobile_add_to_cart",
		AddedToWishlist = "fb_mobile_add_to_wishlist",
		CompletedRegistration = "fb_mobile_complete_registration",
		CompletedTutorial = "fb_mobile_tutorial_completion",
		InitiatedCheckout = "fb_mobile_initiated_checkout",
		Purchased = "fb_mobile_purchase",
		Rated = "fb_mobile_rate",
		Searched = "fb_mobile_search",
		SpentCredits = "fb_mobile_spent_credits",
		UnlockedAchievement = "fb_mobile_achievement_unlocked",
		ViewedContent = "fb_mobile_content_view"
	},
	AppEventParameterName = {
		ContentID = "fb_content_id",
		ContentType = "fb_content_type",
		Currency = "fb_currency",
		Description = "fb_description",
		Level = "fb_level",
		MaxRatingValue = "fb_max_rating_value",
		NumItems = "fb_num_items",
		PaymentInfoAvailable = "fb_payment_info_available",
		RegistrationMethod = "fb_registration_method",
		SearchString = "fb_search_string",
		Success = "fb_success"
	}
}

return FBInAppEvents
