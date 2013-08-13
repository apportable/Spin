package com.apportable.test;

import android.provider.MediaStore;
import android.provider.MediaStore.Audio;
import android.provider.MediaStore.Audio.Artists;
import android.provider.MediaStore.Audio.AudioColumns;

import android.app.Activity;
import android.database.Cursor;

public class MediaQueryApi {

	public MediaQueryApi() {

	}

	public static int hasMusicFile(Activity activity, String artist, String album, String title) {

		String[] projection = {MediaStore.Audio.AudioColumns.ALBUM, MediaStore.Audio.AudioColumns.ARTIST, MediaStore.Audio.AudioColumns.TITLE};
		// Create the cursor pointing to the SDCard
		Cursor cursor = activity.managedQuery(android.provider.MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
		        projection, 
		        MediaStore.Audio.AudioColumns.ALBUM + " like ? AND " + MediaStore.Audio.AudioColumns.ARTIST + " like ? AND " + MediaStore.Audio.AudioColumns.TITLE + " like ?",
		        new String[] {artist, album, title},  
		        null);

		return cursor.getCount();
	}

}