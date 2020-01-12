# LocalYum.me

A marketplace for dinning events written in 2013-2014 with Rails 3. 

## What it does
Hosts (restaurant owners, chefs, food bloggers) can host pre-fixed menu dining events to try out new recipes or promote dishes. 
Yummers (foodies, friends, consumers) can book seats at the events by pre-paying the host. 

During the event, yummers would arrive, present the invite verification and enjoy the meal and event just like they would at a friend of a friend's home. Yummers can leave when they are ready because they have pre-paid.

After the event, hosts can withdraw the funds that was collected for them and host another event. 

## Functionality

### Yummer
User sign up & login via OAuth
Facebook sign up & login
Event - explore, sign up for, add comments, make special request for the event
Rating - give rating (experience & taste) & write review for events

### Hosts
Event listing - create & display event with price, photos, menu, location, and request for guests
Manage events - see who signed up, set booking deadline, max guest count, set cancellation policy
Menu items - ability to upload photo, describe menu item, add recipe
Give guests ability to come for prep time & be a part of making the meal

### Additional Features
Payment via Stripe - manage payment for the host (collect, refund, and withdraw payment)

Cancellation policy - hosts can select from a set of cancellation policies for yummers that involved varying levels of full and partial refund given a certain timeframe until the event.

Messaging system - internal messaging system for host and yummers to have conversations

Email system - internal email system for newsletters, invites, reminders, unsubscribe
