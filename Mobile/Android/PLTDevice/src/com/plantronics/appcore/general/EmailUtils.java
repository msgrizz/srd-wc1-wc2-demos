/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.general;

import android.content.Context;
import android.content.Intent;

/**
 * Created by: Vladimir Petric
 * Date: 03/08/12
 */
public class EmailUtils {

	/**
	 * Starts the email client app.
	 * @param context
	 * 		Caller's context
	 * @param emailToSendTo
	 * 		The email address to send to
	 * @param subject
	 * 		The subject of the email
	 * @param text
	 * 		Email body
	 * @param chooserText
	 * 		The title to be displayed on top of the email client app chooser dialog that will be shown by Android
	 */
    public static void startEmailClient(Context context, String emailToSendTo, String subject, String text, String chooserText) {
        final Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);
        emailIntent.setType("plain/text");
        emailIntent.putExtra(Intent.EXTRA_EMAIL, new String[] {emailToSendTo});
        emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        emailIntent.putExtra(Intent.EXTRA_TEXT, text);
        context.startActivity(Intent.createChooser(emailIntent, chooserText));
    }

}
