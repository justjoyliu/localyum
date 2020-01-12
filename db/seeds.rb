# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# seeding next features
	# Suggestion.create(feature_description: 'checkbox options describing the event setting, such as parking on street, house/apt, pets, etc.', status: 'voting')
	# Suggestion.create(feature_description: 'ability to create/attend events centered around an activity or theme, such as speaking a certain language, cooking demonstration, singles only, etc.', status: 'voting')
	# Suggestion.create(feature_description: 'vote on next features', status: 'liking')

#seeding metro area
	# Metroarea.create(metro_name: 'Other', metro_name_nospace: 'Other')
	# Metroarea.create(metro_name: 'Austin', metro_name_nospace: 'Austin')
	# Metroarea.create(metro_name: 'Boston', metro_name_nospace: 'Boston')
	# Metroarea.create(metro_name: 'Chicago', metro_name_nospace: 'Chicago')
	# Metroarea.create(metro_name: 'New York City', metro_name_nospace: 'NewYorkCity')
	# Metroarea.create(metro_name: 'San Francisco', metro_name_nospace: 'SanFrancisco')
	# Metroarea.create(metro_name: 'Washington DC', metro_name_nospace: 'WashingtonDC')
	# Metroarea.create(metro_name: 'Richmond', metro_name_nospace: 'Richmond')

#seeding event ratings

	# Signup.create(
	# 	hostevent_id: 29, 
	# 	user_id: 4, 
	# 	confirmation_host: true,
	# 	confirmation_guest: true,
	# 	confirmation_status: 'Confirmed')

	# Signup.create(
	# 	hostevent_id: 2, 
	# 	user_id: 3, 
	# 	confirmation_host: true,
	# 	confirmation_guest: true,
	# 	confirmation_status: 'Confirmed',
	# 	payment_status: 'Pending',
	# 	taste_rating: 2 ,
	# 	experience_rating: 3)

	# Signup.create(
	# 	hostevent_id: 2, 
	# 	user_id: 5, 
	# 	confirmation_host: true,
	# 	confirmation_guest: true,
	# 	confirmation_status: 'Confirmed',
	# 	payment_status: 'Pending',
	# 	taste_rating: 5 ,
	# 	experience_rating: 2)

	# Signup.create(
	# 	hostevent_id: 2, 
	# 	user_id: 7, 
	# 	confirmation_host: true,
	# 	confirmation_guest: true,
	# 	confirmation_status: 'Confirmed',
	# 	payment_status: 'Pending',
	# 	taste_rating: 3)
	
#seeding events activities options
	# 	Eventactivity.create(activity: 'Cooking Demonstration')
	#   Eventactivity.create(activity: 'Tasting Menu')
	#   Eventactivity.create(activity: 'Cultural etiquette explaination')

#seeding cancellation policies
		# Cancellationpolicy.create(
		# 	hrs_before_1: 24, hrs_before_2: 0, 
		# 	refund_percent_1: 100, refund_percent_2: 100, 
		# 	cancellation_description: 'Totally Flexible')

		# Cancellationpolicy.create(
		# 	hrs_before_1: 24, hrs_before_2: 0, 
		# 	refund_percent_1: 100, refund_percent_2: 50, 
		# 	cancellation_description: 'Semi Flexible')

		# Cancellationpolicy.create(
		# 	hrs_before_1: 72, hrs_before_2: 24, 
		# 	refund_percent_1: 100, refund_percent_2: 50, 
		# 	cancellation_description: 'Moderate')

		# Cancellationpolicy.create(
		# 	hrs_before_1: 168, hrs_before_2: 72, 
		# 	refund_percent_1: 100, refund_percent_2: 50, 
		# 	cancellation_description: 'Strict')

#seeding charity policies
	# Charitypolicy.create(charityname:'25% to Foodbank', percentcontribute: 25)
	# Charitypolicy.create(charityname:'50% to Foodbank', percentcontribute: 50)

#seeding cuisines
	 	# Eventcategory.create(categorytype:'African')
		# Eventcategory.create(categorytype:'American')
		# Eventcategory.create(categorytype:'Asian')
		# Eventcategory.create(categorytype:'Beer Tasting')
		# Eventcategory.create(categorytype:'BBQ')
		# Eventcategory.create(categorytype:'Brazilian')
		# Eventcategory.create(categorytype:'Caribbean')
		# Eventcategory.create(categorytype:'Chinese')
		# Eventcategory.create(categorytype:'Cuban')
		# Eventcategory.create(categorytype:'Eastern European')
		# Eventcategory.create(categorytype:'Ethiopian')
		# Eventcategory.create(categorytype:'European')
		# Eventcategory.create(categorytype:'Filipino')
		# Eventcategory.create(categorytype:'French')
		# Eventcategory.create(categorytype:'Fusion')
		# Eventcategory.create(categorytype:'German')
		# Eventcategory.create(categorytype:'Greek')
		# Eventcategory.create(categorytype:'Indian')
		# Eventcategory.create(categorytype:'Italian')
		# Eventcategory.create(categorytype:'Japanese')
		# Eventcategory.create(categorytype:'Korean')
		# Eventcategory.create(categorytype:'Kosher')
		# Eventcategory.create(categorytype:'Latin American')
		# Eventcategory.create(categorytype:'Mexican')
		# Eventcategory.create(categorytype:'Middle Eastern')
		# Eventcategory.create(categorytype:'Modern American')
		# Eventcategory.create(categorytype:'Moroccan')
		# Eventcategory.create(categorytype:'Organic')
		# Eventcategory.create(categorytype:'Portuguese')
		# Eventcategory.create(categorytype:'Southern & Soul')
		# Eventcategory.create(categorytype:'Southwestern')
		# Eventcategory.create(categorytype:'Spanish')
		# Eventcategory.create(categorytype:'Tapas')
		# Eventcategory.create(categorytype:'Thai')
		# Eventcategory.create(categorytype:'Turkish')
		# Eventcategory.create(categorytype:'Vegan')
		# Eventcategory.create(categorytype:'Vegitarian')
		# Eventcategory.create(categorytype:'Vietnamese')
		# Eventcategory.create(categorytype:'Whiskey Tasting')
		# Eventcategory.create(categorytype:'Wine Tasting')
