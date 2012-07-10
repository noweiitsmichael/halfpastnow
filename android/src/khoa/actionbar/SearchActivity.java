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

import khoa.actionbar.R;
import khoa.actionbar.CustomItemizedOverlay;
import khoa.actionbar.CustomOverlayItem;


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
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;

import com.readystatesoftware.maps.OnSingleTapListener;
import com.readystatesoftware.maps.TapControlledMapView;


public class SearchActivity extends ActionBarAppActivity implements LocationListener
{
	ImageButton   mButton;
	EditText mEdit;
	LocationManager locationManager;
	Geocoder geocoder;
	 private MapController mapControll;
	    private GeoPoint geoPoint=null;
	    private TapControlledMapView mapview;
	    private MyItemizedOverlay userPicOverlay;
	    private MyItemizedOverlay nearPicOverlay;
	    private Drawable userPic,atmPic;
	    private OverlayItem nearatms[] = new OverlayItem[50];
	    public static Context context;
	    private String imageUrl;
	    private String description="";
	    private String eventName="";
	    private String eventPrice="";
	    private String id="";
	   
	    private String timeString="";
	    private String add1="";
	    private String add2="";
	    private String latitude="";
	    private String longitude="";
	    private String venueID="";
	    private String venueName="";
	    private GeoPoint point;
	   // = new ArrayList<HashMap<String, String>>();
	    
	     
	    TapControlledMapView mapView;
		List<Overlay> mapOverlays;
		Drawable drawable;
		Drawable drawable2;
		CustomItemizedOverlay<CustomOverlayItem> itemizedOverlay;
		khoa.actionbar.SimpleItemizedOverlay itemizedOverlay2;
	public  void onCreate(final Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search);
        
        Log.d("in map view", "");
        mButton = (ImageButton)findViewById(R.id.searchBtn);
	    mEdit   = (EditText)findViewById(R.id.input_text);
	    
        mButton.setOnClickListener(
            new View.OnClickListener()
            {
                public void onClick(View view)
                {
                    getJson(savedInstanceState);
                    
                }
            });
        
		
		
		
//		GeoPoint point = new GeoPoint((int)(51.5174723*1E6),(int)(-0.0899537*1E6));
//		CustomOverlayItem overlayItem = new CustomOverlayItem(point, "Tomorrow Never Dies (1997)", 
//				"(M gives Bond his mission in Daimler car)", 
//				"http://ia.media-imdb.com/images/M/MV5BMTM1MTk2ODQxNV5BMl5BanBnXkFtZTcwOTY5MDg0NA@@._V1._SX40_CR0,0,40,54_.jpg");
//		itemizedOverlay.addOverlay(overlayItem);
//		
//		GeoPoint point2 = new GeoPoint((int)(51.515259*1E6),(int)(-0.086623*1E6));
//		CustomOverlayItem overlayItem2 = new CustomOverlayItem(point2, "GoldenEye (1995)", 
//				"(Interiors Russian defence ministry council chambers in St Petersburg)", 
//				"http://ia.media-imdb.com/images/M/MV5BMzk2OTg4MTk1NF5BMl5BanBnXkFtZTcwNjExNTgzNA@@._V1._SX40_CR0,0,40,54_.jpg");		
//		itemizedOverlay.addOverlay(overlayItem2);
//		
//		mapOverlays.add(itemizedOverlay);
//		
//		// second overlay
//		drawable2 = getResources().getDrawable(R.drawable.marker2);
//		itemizedOverlay2 = new CustomItemizedOverlay<CustomOverlayItem>(drawable2, mapView);
//		
//		GeoPoint point3 = new GeoPoint((int)(51.513329*1E6),(int)(-0.08896*1E6));
//		CustomOverlayItem overlayItem3 = new CustomOverlayItem(point3, "Sliding Doors (1998)", 
//				"(interiors)", null);
//		itemizedOverlay2.addOverlay(overlayItem3);
//		
//		GeoPoint point4 = new GeoPoint((int)(51.51738*1E6),(int)(-0.08186*1E6));
//		CustomOverlayItem overlayItem4 = new CustomOverlayItem(point4, "Mission: Impossible (1996)", 
//				"(Ethan & Jim cafe meeting)", 
//				"http://ia.media-imdb.com/images/M/MV5BMjAyNjk5Njk0MV5BMl5BanBnXkFtZTcwOTA4MjIyMQ@@._V1._SX40_CR0,0,40,54_.jpg");		
//		itemizedOverlay2.addOverlay(overlayItem4);
//		
//		mapOverlays.add(itemizedOverlay2);
//		
//		final MapController mc = mapView.getController();
//		mc.animateTo(point2);
//		mc.setZoom(16);
    
        
     }
	
	public void getJson(Bundle savedInstanceState){
		 Log.v("EditText", " "+ mEdit.getText().toString());
         InputMethodManager inputManager = (InputMethodManager)
         getSystemService(Context.INPUT_METHOD_SERVICE); 
         inboxList = new ArrayList<HashMap<String, String>>();
         inputManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(),InputMethodManager.HIDE_NOT_ALWAYS);
         String key = mEdit.getText().toString();
         HttpPost post = new HttpPost("http://halfpastnow.herokuapp.com/events/index");
     	List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
 		nameValuePairs.add(new BasicNameValuePair("format", "json"));
 		nameValuePairs.add(new BasicNameValuePair("search", key));
 		 MyApplication appState = ((MyApplication)getApplicationContext());
 	        //Set the textview's text using the app's string
 	        Log.d("the String is "," "+appState.getMyApplicationString());
 	    String dayString = appState.getDayString();
 	    String priceString = appState.getPriceString();
 	    String distanceString = appState.getDistanceString();
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
 			
 			
 			
 		} catch (ParseException e) {
 			// TODO Auto-generated catch block
 			e.printStackTrace();
 		} catch (IOException e) {
 			// TODO Auto-generated catch block
 			e.printStackTrace();
 		}

 		/////////////
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
// 	  Log.d(" locationo ", text);
 	    ///////////////////
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
		    				float dist =  currentlocation.distanceTo(locationB)/1609;
		 					
		 					String des = json_data.optString("description");
		 					imageUrl = "";
		 					imageUrl = StringUtils.substringBetween(des, "<img src=\"", "\"");
		 					description = des.replaceAll("<.*?>", "");
		 					eventName = json_data.optString("title");
		 					eventPrice = json_data.optString("price");
		 					id = json_data.optString("id");
		 					
		 					venueName =  venue.optString("name");
		 					JSONArray times  = json_data.getJSONArray("occurrences");
		 					JSONObject time = times.getJSONObject(0);
		 					String startTime = time.optString("start");
		 					String endTime = time.optString("end");
		 					
		 					HashMap<String, String> map = new HashMap<String, String>();
		// 					@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"
		 					SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
		 					Date dateTime = df.parse(startTime);
		 					df = new SimpleDateFormat("K:mm a");
		 					String start = df.format(dateTime);
		 					df = new SimpleDateFormat("EEEE, MMMM d");
		 					String startDate = df.format(dateTime);
		 					String time1 = startDate+" "+start;
		 					timeString = "";
		 					if (endTime == "null"){
		 						timeString = time1;
		 						
		 					}
		 					else {
		 						df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
		 						dateTime = df.parse(endTime);
		 						df = new SimpleDateFormat("K:mm a");
		 						String end1 = df.format(dateTime);
		 						df = new SimpleDateFormat("EEEE, MMMM d");
		 						String endDate = df.format(dateTime);
		 						timeString  = time1 +" to "+end1;
		 					}
		 					if (eventPrice != "null" && !eventPrice.equals(""))
		    				{
		        				if (eventPrice.equals("0.0")) eventPrice = "FREE";
		        				else eventPrice = "$"+eventPrice;
		    				}
		    				else eventPrice = "";
		 					add1 = venue.optString("address");
							add2 = venue.optString("city")+", "+ venue.optString("state")+" "+venue.optString("zip");
							latitude = venue.optString("latitude");
		    				longitude = venue.optString("longitude");
		    				if (imageUrl == null || imageUrl.equals("")) imageUrl = "";
		    				venueID = json_data.optString("venue_id");
		    				venueName  = venue.optString("name");
//		    				HashMap<String, String> mapEvent1 = new HashMap<String, String>();
//		    				mapEvent1.put("EVENT_ID", id );
//		    				mapEvent1.put("EVENTNAME", eventName);
//		    				mapEvent1.put("TIME", timeString);
//		    				mapEvent1.put("DESCRIPTION", description);
//		    				mapEvent1.put("IMAGEURL", imageUrl);
//		    				mapEvent1.put("PRICE", eventPrice);
//		    				mapEvent1.put("ADD1", add1);
//		    				mapEvent1.put("ADD2", add2);
//		    				mapEvent1.put("LAT", latitude);
//		    				mapEvent1.put("LONG", longitude);
//		    				mapEvent1.put("VENUEID", venueID);
//		    				mapEvent1.put("VENUENAME", venueName);
//		    				inboxList.add(mapEvent1);
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

//		    				Log.d("EVENT_ID ", id );
//		    				Log.d("EVENTNAME ", eventName);
//		    				Log.d("TIME ", timeString);
//		    				Log.d("DESCRIPTION ", description);
//		    				Log.d("IMAGEURL", " "+imageUrl);
//		    				Log.d("PRICE ", eventPrice);
//		    				Log.d("ADD1 ", add1);
//		    				Log.d("ADD2 ", add2);
//		    				Log.d("LAT ", latitude);
//		    				Log.d("LONG ", longitude);
//		    				Log.d("VENUEID ", venueID);
//		    				Log.d("VENUENAME ", venueName);
		    				
		    				
		    				

	 				}
	 				
	 				mapView = (TapControlledMapView)  findViewById(R.id.mapview);
	 				mapView.setBuiltInZoomControls(true);
	 				mapView.setOnSingleTapListener(new OnSingleTapListener() {		
	 					@Override
	 					public boolean onSingleTap(MotionEvent e) {
	 						itemizedOverlay.hideAllBalloons();
	 						return true;
	 					}
	 				});

	 				
	 				 appState.setList(inboxList);
	 				
	 				mapOverlays = mapView.getOverlays();
	 				
	 				
	 				
	 			// first overlay
	 				if (distanceString!=null && !distanceString.equals("")){
	 				drawable2 = getResources().getDrawable(R.drawable.marker2);
	 				itemizedOverlay2 = new SimpleItemizedOverlay(drawable2, mapView);
	 				
	 				GeoPoint point = new GeoPoint((int)(currentlocation.getLatitude()*1E6),(int)(currentlocation.getLongitude()*1E6));
	 				OverlayItem overlayItem2 = new OverlayItem(point, "You are here", 
	 						"");
	 				itemizedOverlay2.addOverlay(overlayItem2);
	 				mapOverlays.add(itemizedOverlay2);
	 				
	 				}
	 				
	 				// first overlay
	 				drawable = getResources().getDrawable(R.drawable.marker);
	 				itemizedOverlay = new CustomItemizedOverlay<CustomOverlayItem>(drawable, mapView);
	 				int minLatitude =  Integer.MAX_VALUE;
	 				int maxLatitude = Integer.MIN_VALUE;
	 				int minLongitude = Integer.MAX_VALUE;
	 				int maxLongitude = Integer.MIN_VALUE;
	 				
	 				Log.d("inbox list size ", " "+inboxList.size());
	 				if (distanceString!=null &&!distanceString.equals("")){
		 				 minLatitude = (int) (currentlocation.getLatitude()*1E6);// Integer.MAX_VALUE;
		 				 maxLatitude = (int) (currentlocation.getLatitude()*1E6);// Integer.MIN_VALUE;
		 				 minLongitude = (int)(currentlocation.getLongitude()*1E6);//
		 				 maxLongitude = (int)(currentlocation.getLongitude()*1E6);//
	 				}
	 				else{
	 					 minLatitude =  Integer.MAX_VALUE;
		 				 maxLatitude =  Integer.MIN_VALUE;
		 				 minLongitude = Integer.MAX_VALUE;
		 				 maxLongitude = Integer.MIN_VALUE;
	 				}
	 				for (int i=0; i<inboxList.size();i++){
	 					
	 					HashMap<String, String> mapEventT = new HashMap<String, String>();
	 					mapEventT = inboxList.get(i);
	 					String eventTitle =  mapEventT.get("EVENTNAME");
	 					String eventLocation =  mapEventT.get("VENUENAME");
	 					String eventPrice = mapEventT.get("PRICE");
	 					String eventTime =  mapEventT.get("TIME");
	 					String imageURL =  mapEventT.get("IMAGEURL");
	 					String latitude = mapEventT.get("LAT");
	 					String longitude = mapEventT.get("LONG");
	 					 String EVENT_ID =  mapEventT.get("EVENT_ID");
	 					 String EVENTNAME =  mapEventT.get("EVENTNAME");
	 					 String DESCRIPTION =  mapEventT.get("DESCRIPTION");
	 					 String ADD1 =  mapEventT.get("ADD1");
	 					 String ADD2 =  mapEventT.get("ADD2");
	 					 String LAT =  mapEventT.get("LAT");
	 					 String LONG =  mapEventT.get("LONG");
	 					 String VENUEID =  mapEventT.get("VENUEID");
	 					 String VENUENAME =  mapEventT.get("VENUENAME");
	 					String DISTANCE =  mapEventT.get("DISTANCE");
	 					 int latTemp = (int)(Float.parseFloat(latitude)*1E6) ;
	 					 int lngTemp = (int)(Float.parseFloat(longitude)*1E6);
	 					point = new GeoPoint(latTemp,lngTemp);
	 					
	 						
	 					CustomOverlayItem overlayItem = new CustomOverlayItem(point, eventTitle, 
	 							eventLocation, 
	 							imageURL,
	 							eventTime,eventLocation,eventPrice,EVENT_ID,EVENTNAME,DESCRIPTION,ADD1,ADD2,LAT,LONG,VENUEID,VENUENAME,DISTANCE);
	 					itemizedOverlay.addOverlay(overlayItem);
	 					maxLatitude = Math.max(latTemp, maxLatitude);
	 					minLatitude = Math.min(latTemp, minLatitude);
	 					maxLongitude = Math.max(lngTemp, maxLongitude);
	 					minLongitude = Math.min(lngTemp, minLongitude);
//	 					Log.d("title ", " "+eventTitle);
//	 					Log.d("price ", " "+eventPrice);
//	 					Log.d("time ", " "+eventTime);
//	 					Log.d("imageURL ", " "+imageURL);
//	 					Log.d("Location ", " "+eventLocation);
	 					
	 					
	 					
	 				}
	 				mapOverlays.add(itemizedOverlay);
	 				if (savedInstanceState == null) {
	 					
	 					final MapController mc = mapView.getController();
	 					mc.zoomToSpan(Math.abs(maxLatitude - minLatitude), Math.abs(maxLongitude - minLongitude));
	 					
	 					mc.animateTo(new GeoPoint( 
	 							(maxLatitude + minLatitude)/2, 
	 							(maxLongitude + minLongitude)/2 )); 
//	 					mc.animateTo(point);
//	 					mc.setZoom(16);
	 					
	 				} else {
	 					
	 					// example restoring focused state of overlays
	 					int focused;
	 					focused = savedInstanceState.getInt("focused_1", -1);
	 					if (focused >= 0) {
	 						itemizedOverlay.setFocus(itemizedOverlay.getItem(focused));
	 					}
	 					focused = savedInstanceState.getInt("focused_2", -1);
	 					if (focused >= 0) {
	 						itemizedOverlay2.setFocus(itemizedOverlay2.getItem(focused));
	 					}
	 					
	 				}
 					
// 					final MapController mc = mapView.getController();
// 					mc.animateTo(point);
// 					mc.setZoom(16);
 				}
 			catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (java.text.ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			
		
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
	public void onAbout(View v)
    {
    	//Toast.makeText (getApplicationContext(),"Set filter here" , Toast.LENGTH_LONG).show ();
    	
    	startActivity (new Intent(getApplicationContext(), FilterActivity.class));
               
            
      
    }
	@Override
	protected boolean isLocationDisplayed() {
	// TODO Auto-generated method stub
		Log.d("in isLocationDisplayed","");
	return false;
	}
//	@Override
//	protected void onSaveInstanceState(Bundle outState) {
//		
//		// example saving focused state of overlays
//		if (itemizedOverlay.getFocus() != null) outState.putInt("focused_1", itemizedOverlay.getLastFocusedIndex());
//		if (itemizedOverlay2.getFocus() != null) outState.putInt("focused_2", itemizedOverlay2.getLastFocusedIndex());
//		super.onSaveInstanceState(outState);
//	
//	}
	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		Log.d("in isRouteDisplay()","");
		return false;
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		//locationManager.removeUpdates(this);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		//locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 10, this);
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
