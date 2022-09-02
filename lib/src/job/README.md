# Job

Job functionality using FireFlutter


# TODO

- Let user to update the post creation date.

# Overview

- We put the `job` as an extra feature because it is not a general functionality that most apps requires.
- And we put `job` data on different firestore collection since it needs a lot more indexes than post.
  - `Forum` functioanlity of fireflutter is a good function to extends many extra feature. But we simply separate the job function from forum function to make it simple.

# Conditions and rules

- A user can create only one job opening.
  - So if the user needs more than one job opening, he can create another account.
  - For this reason, it does not block creating a job opening when there is same name of company or same number of phone.
- Creating job opening deducts user's point. To update the amount of pint, refer `Job.pointDeductionForCreation` in job class.


# Logics

- When a user creates a job opening, then the app collects from the input form and sent it to cloud function via http call.
- Then, cloud function does
  - Checking the input data
  - Check if the user has a job opening already. (User can create only one job opening.)
  - Check if the user has enough point to create
  - Create the job opening.
  - Deduct point and and leave the point history in `/point/<uid>/extra`.
    - Then, later the app can get display the job creating point deduction on his point history list screen.



# Administration

- Admin must create `jobOpenings` and `jobSeekers` categories and group them as `job`.


# Job Notification

- User can set notification based on the combination of search option.
  - For instance, User A wants to subscribe notification if there is a new job opening on IT in Gyungi-do, dong-hae city.
    - And A can subscribe as much notification as he wants.

- Job notification should not appear on user's notification settings since it will be available on job search screen with search combinations.







# Unit testing

- run `npm run test:job`.

