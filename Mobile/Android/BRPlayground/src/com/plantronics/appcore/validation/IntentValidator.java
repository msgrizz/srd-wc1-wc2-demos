package com.plantronics.appcore.validation;
import com.plantronics.appcore.debug.CoreLogTag;

import android.content.Intent;
import android.util.Log;

/**
 * Class for validation of the passed {@link Intent}
 * 
 * Created by: Zivorad Baralic
 * Date: 10/23/12
 */

public class IntentValidator {

	// ==================================================================================================================
	// Constants
	// ==================================================================================================================
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + IntentValidator.class.getSimpleName();

	// ==================================================================================================================
	// Public interface methods
	// ==================================================================================================================

	/**
	 * Validates if the given {@link Intent} object is different from null and has valid action.
	 * 
	 * @param intent
	 *            The Intent object
	 * @return The outcome of validation
	 */
	public boolean isOkay(Intent intent) { // Defensive programming
		if (intent == null) {
			Log.e(TAG, "Null intent!");
			return false;
		}
		String action = intent.getAction();
		if (action == null) {
			Log.e(TAG, "Null intent action!");
			return false;
		}
		return true;
	}

}
