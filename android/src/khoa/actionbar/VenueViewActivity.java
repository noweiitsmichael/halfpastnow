package khoa.actionbar;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
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
//import org.json.JSONArray;
//import org.json.JSONException;
//import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import khoa.actionbar.JSONParser;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;

public class VenueViewActivity extends MapActivity{
	private String venueID="";
	private String[] array = {"SUN","MON","TUE","WED","THU","FRI","SAT"};
	private JSONParser jsonParser = new JSONParser();
	EditText mEdit;
	
	private LinearLayout getLinearLayout;
	ArrayList<HashMap<String, String>> inboxList;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        
        
        getWindow().setSoftInputMode( WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        
        this.getWindow().setSoftInputMode(
        		WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        		requestWindowFeature(Window.FEATURE_NO_TITLE);
        		setContentView(R.layout.venue);
        		mEdit = (EditText)findViewById(R.id.input_text_main);
        		getLinearLayout = (LinearLayout)findViewById(R.id.overview);
        		
        
        
        Bundle extras = getIntent().getExtras();
        inboxList = new ArrayList<HashMap<String, String>>();
        if(extras !=null) {
        	venueID = extras.getString("VENUEID");
        }
        Log.d("Venue button ", "clicked "+venueID);
        HttpPost post = new HttpPost("http://halfpastnow.herokuapp.com//venues/show/"+venueID+".json");
    	List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
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
			//Log.d("Inbox JSON: ",""+ responseText);
			
			
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			JSONObject jObject = new JSONObject(responseText.toString());
			String venueString =  jObject.optString("venue");
			JSONObject venue = new JSONObject(venueString);
			String venueName = venue.optString("name");
			TextView venueNameText=(TextView) findViewById(R.id.venueName);
			venueNameText.setText(venueName);
			String venueAdd1 = venue.optString("address");
			TextView venueAdd1Text=(TextView) findViewById(R.id.venueAdd1);
			venueAdd1Text.setText(venueAdd1);
			String venueAdd2 = venue.optString("city")+", "+ venue.optString("state")+" "+venue.optString("zip");
			TextView venueAdd2Text=(TextView) findViewById(R.id.venueAdd2);
			venueAdd2Text.setText(venueAdd2);
			String venuePhone = venue.optString("phonenumber");
			TextView venuePhoneText=(TextView) findViewById(R.id.venuePhone);
			venuePhoneText.setText(venuePhone);
			String latitude = venue.optString("latitude");
			String longitude= venue.optString("longitude");
			
			MapView mapView = (MapView) findViewById(R.id.customvenuemapview);
	        mapView.setBuiltInZoomControls(true);
	      
	        Drawable marker=getResources().getDrawable(android.R.drawable.star_big_on);
	        int markerWidth = marker.getIntrinsicWidth();
	        int markerHeight = marker.getIntrinsicHeight();
	        marker.setBounds(0, markerHeight, markerWidth, 0);
	    
	      
	        MyItemizedOverlay myItemizedOverlay = new MyItemizedOverlay(marker);
	        mapView.getOverlays().add(myItemizedOverlay);
//	      30.268149,-97.742829
	        String coordinates[] = {latitude, longitude};
	        double lat = Double.parseDouble(coordinates[0]);
	        double lng = Double.parseDouble(coordinates[1]);
	 
	        GeoPoint p = new GeoPoint(
	            (int) (lat * 1E6), 
	            (int) (lng * 1E6));
	        GeoPoint myPoint1 = new GeoPoint(0*1000000, 0*1000000);
	        myItemizedOverlay.addItem(p, "myPoint1", "myPoint1");
	        GeoPoint myPoint2 = new GeoPoint(50*1000000, 50*1000000);
	        MapController mapController = mapView.getController();
	        mapController.setCenter(p);
	        mapController.setZoom(14);
	        ///////////////
	        String recurrencesString =  jObject.optString("recurrences");
	        JSONArray recurrences = new JSONArray(recurrencesString);
	        String timeEvent;
	        for(int i=0;i<recurrences.length();i++)
	        {
	        	String mod;
	        	String day;
	        	HashMap<String, String> map = new HashMap<String, String>();
	        	JSONObject   json_data = recurrences.getJSONObject(i);
	        	int m = json_data.optInt("every_other");
	            mod = "EVERY " + ((m == 0) ? "" : ((m == 1) ? "OTHER" : to_ordinal(m)));
	            int dow;
	            int wom;
	            int dom;
	            dow = json_data.optInt("day_of_week");
	            wom = json_data.optInt("week_of_month");
	            dom = json_data.optInt("day_of_month");
	            String dayString = (dow!=0 && wom!=0) ? 
	            		to_ordinal(wom) + " " + array[dow] :
	            			(dom!=0 ? to_ordinal(dom)  :
	            				(dow!=0 ? array[dow] : "DAY"));
	            String startString = json_data.optString("start");
	        	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
				Date dateTime = null;
				try {
					dateTime = df.parse(startString);
				} catch (java.text.ParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				df = new SimpleDateFormat("K:mm a");
				String start = df.format(dateTime);
				timeEvent = mod+" "+dayString+" at "+start;
				Log.d("Event time: ",timeEvent);
				String eventString =  json_data.optString("event");
				json_data = new JSONObject(eventString);
				map.put("ADD1", venueAdd1);
				map.put("ADD2", venueAdd2);
				// adding each child node to HashMap key => value
				String eventName = json_data.optString("title");
				map.put("EVENTNAME", eventName);
				map.put("TIME", timeEvent);
				String eventPrice = json_data.optString("price");
				if (eventPrice != "null" && !eventPrice.equals(""))
				{
    				if (eventPrice.equals("0.0")) map.put("PRICE", "FREE");
    				else map.put("PRICE", "$"+eventPrice);
				}
				else map.put("PRICE", "");
				map.put("LAT", latitude);
				map.put("LONG", longitude);
				
				map.put("EVENTLOCATION", venueName);
				String id = json_data.optString("event_id");
				map.put("ID", id);
				map.put("VENUEID",json_data.optString("venue_id"));
				map.put("VENUENAME",venueName);
				
				String des = json_data.optString("description");
				String imageUrl = "";
				imageUrl = StringUtils.substringBetween(des, "<img src=\"", "\"");
				String description = des.replaceAll("<.*?>", "");
				
				map.put("DESCRIPTION",description);
				if (imageUrl != null && !imageUrl.equals(""))map.put("IMAGEURL", imageUrl);
				else map.put("IMAGEURL", "");

				// adding HashList to ArrayList
				inboxList.add(map);
				
				
				//////////////////
				
	        }
	        /////////////
	        String occurencesString =  jObject.optString("occurrences");
	        JSONArray occurrences = new JSONArray(occurencesString);
	        for(int i=0;i<occurrences.length();i++)
	        {
	        	HashMap<String, String> map = new HashMap<String, String>();
	        	JSONObject json_data = occurrences.getJSONObject(i);
	        	String startTime = json_data.optString("start");
	        	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss-ss:ss");
				Date dateTime = null;
				try {
					dateTime = df.parse(startTime);
				} catch (java.text.ParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				df = new SimpleDateFormat("K:mm a");
				String start = df.format(dateTime);
				df = new SimpleDateFormat("EEEE, MMMM d");
				String startDate = df.format(dateTime);
				timeEvent = startDate+" "+start;
				Log.d("Event time: ",timeEvent);
				String eventString =  json_data.optString("event");
				json_data = new JSONObject(eventString);
				
				map.put("ADD1", venueAdd1);
				map.put("ADD2", venueAdd2);
				// adding each child node to HashMap key => value
				String eventName = json_data.optString("title");
				map.put("EVENTNAME", eventName);
				map.put("TIME", timeEvent);
				String eventPrice = json_data.optString("price");
				if (eventPrice != "null" && !eventPrice.equals(""))
				{
    				if (eventPrice.equals("0.0")) map.put("PRICE", "FREE");
    				else map.put("PRICE", "$"+eventPrice);
				}
				else map.put("PRICE", "");
				map.put("LAT", latitude);
				map.put("LONG", longitude);
				
				map.put("EVENTLOCATION", venueName);
				String id = json_data.optString("event_id");
				map.put("ID", id);
				map.put("VENUEID",json_data.optString("venue_id"));
				map.put("VENUENAME",venueName);
				
				String des = json_data.optString("description");
				String imageUrl = "";
				imageUrl = StringUtils.substringBetween(des, "<img src=\"", "\"");
				String description = des.replaceAll("<.*?>", "");
				
				map.put("DESCRIPTION",description);
				if (imageUrl != null && !imageUrl.equals(""))map.put("IMAGEURL", imageUrl);
				else map.put("IMAGEURL", "");

				// adding HashList to ArrayList
				inboxList.add(map);
	        }
	        
	        
	        ///////////
	        ListView listView = (ListView) findViewById(R.id.listVenue);
        	LazyAdapterVenue adapter = new LazyAdapterVenue(
			VenueViewActivity.this, inboxList);
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
			
			
			
			
			
			
			
			
			
			
	        
			
			
		}
	    catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    

    }

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
	
	public void onAbout(View v)
    {
    	//Toast.makeText (getApplicationContext(),"Set filter here" , Toast.LENGTH_LONG).show ();
    	
    	startActivity (new Intent(getApplicationContext(), FilterActivity.class));
               
            
      
    }
    
    public void onSearch(View v)
    {
    	mEdit   = (EditText)findViewById(R.id.input_text_main);
    	
    	Intent intent = new Intent(getBaseContext(), FindActivity.class);
    	intent.putExtra("KEY", mEdit.getText().toString());
        startActivity (intent);
    }
    public void onSearchView(View v)
    {
    	startActivity (new Intent(getApplicationContext(), SearchActivity.class));
    }
    public void onHome (View v)
    {
    	return2Home(this);
    }
    
    public void return2Home(Context context)
    {
        final Intent intent = new Intent(context, HomeActivity.class);
        intent.setFlags (Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity (intent);
    }
	
	public String to_ordinal(int num){
		String[] array = {"th","st","nd","rd","th","th","th","th","th","th"}; 
		int n = num % 10;
		String tmp = array[n];
		return  (num + tmp);
	}
}
