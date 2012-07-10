package khoa.actionbar;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;

import android.content.Context;
import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

public class FindActivity extends ActionBarAppActivity implements LocationListener{

	LocationManager locationManager;
	Geocoder geocoder;
	TextView locationText;
	MapView map;	
	MapController mapController;
	public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
//        InputMethodManager inputManager = (InputMethodManager)
//        getSystemService(Context.INPUT_METHOD_SERVICE); 
//        inputManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
    	inboxList = new ArrayList<HashMap<String, String>>();
    	Log.d("Here Find activity", "clicked");
    	Bundle extras = getIntent().getExtras();
    	String key = extras.getString("KEY");
    	//////////
    	List<NameValuePair> params = new ArrayList<NameValuePair>();
    	HttpPost post = new HttpPost("http://halfpastnow.herokuapp.com/events/index");
    	List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
		nameValuePairs.add(new BasicNameValuePair("format", "json"));
		nameValuePairs.add(new BasicNameValuePair("search", key));
		 MyApplication appState = ((MyApplication)getApplicationContext());
	        //Set the textview's text using the app's string
	        Log.d("the String is "," "+appState.getMyApplicationString());
	        String distanceString ="";
	    String dayString = appState.getDayString();
	    String priceString = appState.getPriceString();
	    distanceString = appState.getDistanceString();
	    String todayOrTomorrowString = appState.getTodayOrTomorrowString();
	    
	    nameValuePairs.add(new BasicNameValuePair("search", key));
	    
	    GregorianCalendar calendar = new GregorianCalendar();
	    Calendar now = Calendar.getInstance();
	    String nowString = ""+Math.round((now.getTimeInMillis()/1000));
	    now.add(Calendar.DATE, 1);
	    String day1String =  ""+Math.round(now.getTimeInMillis()/1000);
	    now.add(Calendar.DATE, 1);
	    String day2String =  ""+Math.round(now.getTimeInMillis()/1000);
	    now.add(Calendar.DATE, 365);
	    String daysString =  ""+Math.round(now.getTimeInMillis()/1000);
	    
	    Log.d("Now ", " "+nowString);
	    Log.d("day1 "," "+ day1String);
	    Log.d("day2 "," "+ day2String);
	    Log.d("days "," "+ daysString);
	   
//	    nameValuePairs.add(new BasicNameValuePair("start", nowString));
//    	nameValuePairs.add(new BasicNameValuePair("end", day1String));
	    if (todayOrTomorrowString!=null&&todayOrTomorrowString.equals("0")) {
	    	nameValuePairs.add(new BasicNameValuePair("start", nowString));
	    	nameValuePairs.add(new BasicNameValuePair("end", day1String));
	    }
	    else if (todayOrTomorrowString!=null&&todayOrTomorrowString.equals("1")) {
	    	nameValuePairs.add(new BasicNameValuePair("start", day1String));
	    	nameValuePairs.add(new BasicNameValuePair("end", day2String));
	    }
	    else
	    {
	    	nameValuePairs.add(new BasicNameValuePair("start", nowString));
	    	nameValuePairs.add(new BasicNameValuePair("end", daysString));
	    }
	    if(dayString!=null&&!dayString.equals(""))nameValuePairs.add(new BasicNameValuePair("day", dayString));
	    if(priceString!=null&&!priceString.equals(""))nameValuePairs.add(new BasicNameValuePair("price", priceString));
    	 
		try {
			post.setEntity(new UrlEncodedFormEntity(nameValuePairs));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		HttpClient client = new DefaultHttpClient();
		HttpResponse response = null;
		try {
			response = client.execute(post);
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		HttpEntity entity = response.getEntity();
		String responseText="";
		try {
			responseText = EntityUtils.toString(entity);
			Log.d("Inbox JSON: ", responseText);
			
			
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		LocationManager lm;
	 	   
 	    boolean gps_enabled=false;
 	    boolean network_enabled=false;
 		
 	    locationManager = (LocationManager)this.getSystemService(LOCATION_SERVICE);

       geocoder = new Geocoder(this);
       
       Location currentlocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
       if (currentlocation != null) {
       	Log.d(" ", currentlocation.toString());
       	this.onLocationChanged(currentlocation);	
       }
 	   String text = String.format("Lat:\t %f\nLong:\t %f\n", currentlocation.getLatitude(), 
               currentlocation.getLongitude());
 	  String distance="";
 	  
 	  Log.d(" locationo ", "");
		
			try {
				JSONArray jArray = new JSONArray(responseText);
				for(int i=0;i<jArray.length();i++)
		        {
					JSONObject   json_data = jArray.getJSONObject(i);
					JSONObject venue  = json_data.getJSONObject("venue");
					String latitude = venue.optString("latitude");
    				String longitude = venue.optString("longitude");
					
    				Location locationB = new Location("point B");

    				locationB.setLatitude(Float.parseFloat(latitude));
    				locationB.setLongitude(Float.parseFloat(longitude));

    				distance =String.format("%.1f", currentlocation.distanceTo(locationB)/1609)+" mi";
    				Log.d("Distance ", ""+distance);
    				float dist = currentlocation.distanceTo(locationB)/1609;
					
					
					
					String des = json_data.optString("description");
					String imageUrl = "";
					imageUrl = StringUtils.substringBetween(des, "<img src=\"", "\"");
					String description = des.replaceAll("<.*?>", "");
					String eventName = json_data.optString("title");
					String eventPrice = json_data.optString("price");
					String id = json_data.optString("id");
					
					String venueName =  venue.optString("name");
					JSONArray times  = json_data.getJSONArray("occurrences");
					JSONObject time = times.getJSONObject(0);
					String startTime = time.optString("start");
					String endTime = time.optString("end");
					
					
//					@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"
					SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
					Date dateTime = df.parse(startTime);
					df = new SimpleDateFormat("K:mm a");
					String start = df.format(dateTime);
					df = new SimpleDateFormat("EEEE, MMMM d");
					String startDate = df.format(dateTime);
					Log.d("Start : ",""+startTime);
					Log.d("Parsed start : ",startDate+" "+start);
					String time1 = startDate+" "+start;
					Log.d("End ",""+endTime);
					String timeString = "";
					if (endTime == "null"){
						timeString = time1;
						
					}
					else {
						Log.d("End time:",""+endTime);
						df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
						dateTime = df.parse(endTime);
						df = new SimpleDateFormat("K:mm a");
						String end1 = df.format(dateTime);
						df = new SimpleDateFormat("EEEE, MMMM d");
						String endDate = df.format(dateTime);
						timeString  = time1 +" to "+end1;
					}

					// adding each child node to HashMap key => value
    				
    				
					if (eventPrice != "null" && !eventPrice.equals(""))
    				{
        				if (eventPrice.equals("0.0")) eventPrice = "FREE";
        				else eventPrice = "$"+eventPrice;
    				}
    				else eventPrice = "";
					
					String add1 = venue.optString("address");
					String add2 = venue.optString("city")+", "+ venue.optString("state")+" "+venue.optString("zip");
					
    				if (imageUrl == null || imageUrl.equals("")) imageUrl = "";
    				String venueID = json_data.optString("venue_id");
    				venueName  = venue.optString("name");
					
    				
    				
    				
    				

    				if (imageUrl == null || imageUrl.equals("")) imageUrl = "";
    				
    				

    				// adding HashList to ArrayList
   				if (distanceString==null||distanceString==""){
   					inputMap( venueName, id,  eventName, timeString,
   						 description,  imageUrl,  eventPrice,
   						 add1,  add2,  latitude,  longitude,
   						 venueID, "", inboxList);
   				}
   				
   				else if (distanceString=="0"&&dist<0.5){
   					inputMap( venueName, id,  eventName, timeString,
   						 description,  imageUrl,  eventPrice,
   						 add1,  add2,  latitude,  longitude,
   						 venueID, distance, inboxList);
   				}
   				else if (distanceString=="1"&&dist<1){
   					inputMap( venueName, id,  eventName, timeString,
      						 description,  imageUrl,  eventPrice,
      						 add1,  add2,  latitude,  longitude,
      						 venueID, distance, inboxList);
      				}
   				else if (distanceString=="2"&&dist<2){
   					inputMap( venueName, id,  eventName, timeString,
      						 description,  imageUrl,  eventPrice,
      						 add1,  add2,  latitude,  longitude,
      						 venueID, distance, inboxList);
      				}
   				else if (distanceString=="3"&&dist>2){
   					inputMap( venueName, id,  eventName, timeString,
      						 description,  imageUrl,  eventPrice,
      						 add1,  add2,  latitude,  longitude,
      						 venueID, distance, inboxList);
      				}


		        }
				
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (java.text.ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
  		
    	/////////
    	ListView listView = (ListView) findViewById(R.id.list);
    	LazyAdapter adapter = new LazyAdapter(
		FindActivity.this, inboxList);
		// updating listview
		
    	listView.setAdapter(adapter);
		
    	listView.setOnItemClickListener(new OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {  
            	HashMap<String, String> map = new HashMap<String, String>();
                map = inboxList.get(position);
                
            	Log.d("clicked", ""+map.get("ID")+" "+map.get("EVENTNAME"));
            	Intent intent = new Intent(getBaseContext(), EventViewActivity.class);
            	intent.putExtra("EVENT_ID", map.get("ID"));
            	intent.putExtra("EVENTNAME", map.get("EVENTNAME"));
            	intent.putExtra("TIME", map.get("TIME"));
            	intent.putExtra("DESCRIPTION", map.get("DESCRIPTION"));
            	intent.putExtra("IMAGEURL", map.get("IMAGEURL"));
            	intent.putExtra("PRICE", map.get("PRICE"));
            	intent.putExtra("ADD1", map.get("ADD1"));
            	intent.putExtra("ADD2", map.get("ADD2"));
            	intent.putExtra("LAT", map.get("LAT"));
            	intent.putExtra("LONG", map.get("LONG"));
            	intent.putExtra("VENUEID", map.get("VENUEID"));
            	intent.putExtra("VENUENAME", map.get("VENUENAME"));
            	
            	
            	startActivity(intent);
                
            }
        });
    	/////////////////////////
    	 
    	
  }
     
	public void inputMap(String venueName,String id, String eventName,String timeString,
			String description, String imageUrl, String eventPrice,
			String add1, String add2, String latitude, String longitude,
			String venueID, String distance, ArrayList<HashMap<String, String>> inboxList)
	   {
		HashMap<String, String> map = new HashMap<String, String>();
		map.put("EVENTLOCATION", venueName);
		map.put("EVENT_ID", id );
		map.put("EVENTNAME", eventName);
		map.put("TIME", timeString);
		map.put("DESCRIPTION", description);
		map.put("IMAGEURL", imageUrl);
		map.put("PRICE", eventPrice);
		map.put("ADD1", add1);
		map.put("ADD2", add2);
		map.put("LAT", latitude);
		map.put("LONG", longitude);
		map.put("VENUEID", venueID);
		map.put("VENUENAME", venueName);
		map.put("DISTANCE", distance);
		inboxList.add(map); 
	   }

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		locationManager.removeUpdates(this);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 1000, 10, this);
	}
    
	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void onLocationChanged(Location location) {
		// TODO Auto-generated method stub
		Log.d(" ", "onLocationChanged with location " + location.toString());
		// Displays lat, long, altitude and bearing
		String text = String.format("Lat:\t %f\nLong:\t %f\nAlt:\t %f\nBearing:\t %f", location.getLatitude(), location.getLongitude(), location.getAltitude(), location.getBearing());
		
	}

	@Override
	public void onProviderDisabled(String provider) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onProviderEnabled(String provider) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {
		// TODO Auto-generated method stub
		
	}
}
