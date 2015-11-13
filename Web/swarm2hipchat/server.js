/**
 * Swarm to HipChat integration - assumes that there is a Bot created for a particular
 * HipChat room.
 *
 */

var request = require('request');
var FeedParser = require('feedparser');
var http = require('http');

var lastRSSItem;
var itemArray = new Array();
var rssUrl = 'http://swarm.plantronics.com/activity/streams/project-wearable-concept-2/rss';
var roomURL = 'https://pltlabs.hipchat.com/v2/room/2159522/notification?auth_token=kUbzFIDHhsXEyFAXuaC65GJiL08NOUIiUot4BKq8';

function getSwarmRss() {
   var req = request(rssUrl, {timeout: 30000, pool: false});
   var fp = new FeedParser();

   console.log('Fetching Swarm RSS feed');

   req.on('error', function(error){
    console.log('error connecting: ' + error);
   });

   req.on('response', function(res){
    var stream = this;
    if (res.statusCode != 200) {
     console.log('response error!');
     return this.emit('error', new Error('Bad response: status code ' + res.statusCode));
    }
    stream.pipe(fp);
   });

   fp.on('error', function(error){
    console.log('error parsing rss: ' + error);
    });

    //when we get here the feed parser has ripped through all the xml returned
    //back by the Swarm server
   fp.on('end', function(){
    var lastKnownDate = new Date(lastRSSItem.pubdate);
    for(i in itemArray){
        var date = new Date(i.pubdate);
        if (lastKnownDate.getTime() < date.getTime()) {
            lastRSSItem = i;
            lastKnownDate = date;
        }
    }
    //clear out the array
    itemArray.length = 0;
    console.log('Finished parsing Swarm RSS');
    console.log('last known Swarm item is ' + lastRSSItem.link);

   });
   fp.on('readable', function(){
    var stream = this;
    var meta = this.meta;
    var item;

    var firstItem;
    while(item = stream.read()){
       if (typeof lastRSSItem === "undefined") {
            //set the last known RSSI element
            console.log("First running recording the last known Swarm Event");
            lastRSSItem = item;
            sendMessageToHipChat(item);
            continue;
        }

        var date = new Date(item.pubdate);
        var lastKnownDate = new Date(lastRSSItem.pubdate);
        console.log("Incoming Swarm item, comparing timestamps between: " + item.link + " and latest recorded item " + lastRSSItem.link);
        console.log(item.link + " timestamp = " + date.getTime());
        console.log(lastRSSItem.link + " timestamp = " + lastKnownDate.getTime());

        if (date.getTime() > lastKnownDate.getTime()) {
            console.log(item.link + " is newer than the last recorded Swarm item");
            itemArray.push(item);
            sendMessageToHipChat(item);
        }
    }
    console.log("\n\n");

  });
}

function sendMessageToHipChat(rssItem){
    console.log("sending message to HipChat");

    var issueLink = rssItem.meta.link + rssItem.link.substring(1);
    var issueNumber = rssItem.link.substring(1);
    issueNumber = issueNumber.substring(issueNumber.indexOf('/') + 1);

    console.log("meta: link " + issueLink + " issue number " + issueNumber);
    var message = {
        "message_format":"html",
        "color":"purple",
        "notify":"true",
        "message":"<b>Swarm Notification!</b><br>" +
        "<ul><li>Title: " + rssItem.title + "</li><li>Review link: <a href='" + issueLink + "'>" + issueNumber+ "</a></li></ul>"
    };
        // fire request
  request({
        url: roomURL,
        method: "POST",
        json: true,
        headers: {
            "content-type": "application/json"
        }},
        function(response){console.log('response from HipChat ' + response);}).write(JSON.stringify(message));

}


var server = http.createServer(function (req, res) {
  res.writeHead(200);
  res.end('Hello, World!\n');
});

server.listen(8888, function () {
  setInterval(getSwarmRss, 10000);
});
