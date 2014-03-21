package com.plantronics.PLTDevice;

import com.plantronics.PLTDevice.info.Info;

/**
 * Created by mdavis on 1/16/14.
 */

public interface InfoListener {

	public void onSubscriptionChanged(Subscription oldSubscription, Subscription newSubscription);
	public void onInfoReceived(Info info);
}
