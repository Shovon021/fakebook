HOW TO ADD YOUR OWN PHOTOS
==========================

1. Paste your photo files (e.g. `my_photo.jpg`, `friend.png`) into this folder (`assets/images/`).
   
2. Open `lib/data/dummy_data.dart`.

3. Find the user you want to update (e.g. `currentUser` or someone in `users` list).

4. Change their `avatarUrl` or `imageUrl` to the path of your photo.
   Example:
   
   FROM:
   avatarUrl: 'https://example.com/photo.jpg',
   
   TO:
   avatarUrl: 'assets/images/my_photo.jpg',

5. Reload the app (Press 'R' in terminal or restart).

That's it! The app will automatically detect it's a local file and load it.
