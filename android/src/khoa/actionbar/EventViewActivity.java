package khoa.actionbar;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

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
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
 
public class EventViewActivity extends MapActivity{
    
	private String venueID;
	EditText mEdit;
	ImageButton   pixButton;
	Button p1_button;
	
	private LinearLayout getLinearLayout;
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setSoftInputMode( WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        
        this.getWindow().setSoftInputMode(
        		WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        		requestWindowFeature(Window.FEATURE_NO_TITLE);
        		setContentView(R.layout.custom);

        		mEdit = (EditText)findViewById(R.id.input_text_main);
        		getLinearLayout = (LinearLayout)findViewById(R.id.overview);
        		
        
        		Bundle extras = getIntent().getExtras();
        String value="";
        String eventTitle="";
        String eventTime ="";
        String description="";
        String urlImage="";
        String price="";
        String add1="";
        String add2="";
        String latitude ="";
        String longitude ="";
        String venueName ="";
        
        if(extras !=null) {
        	value = extras.getString("EVENT_ID");
        	eventTitle = extras.getString("EVENTNAME");
        	eventTime = extras.getString("TIME");
        	description = extras.getString("DESCRIPTION");
        	urlImage = extras.getString("IMAGEURL");
        	price = extras.getString("PRICE");
        	add1 = extras.getString("ADD1");
        	add2 = extras.getString("ADD2");
        	latitude = extras.getString("LAT");
        	longitude = extras.getString("LONG");
        	venueName =  extras.getString("VENUENAME");
        	venueID = extras.getString("VENUEID");
            
        }
        
       
		TextView eventNameText=(TextView) findViewById(R.id.customEventName);
        eventNameText.setText(eventTitle);
        TextView eventTimeText=(TextView) findViewById(R.id.customEventTime);
        eventTimeText.setText(eventTime);
        TextView eventDesText=(TextView) findViewById(R.id.customEventDescription);
        eventDesText.setText(description);
        TextView eventPriceText=(TextView) findViewById(R.id.customEventPrice);
        eventPriceText.setText(price);
        TextView eventAdd1Text=(TextView) findViewById(R.id.customAdd1);
        eventAdd1Text.setText(add1);
        TextView eventAdd2Text=(TextView) findViewById(R.id.customAdd2);
        eventAdd2Text.setText(add2);
        p1_button = (Button) findViewById(R.id.customEventVenue);
        p1_button.setText(venueName);
        

        
        ImageView image=(ImageView) findViewById(R.id.customEventImage);
        if (!urlImage.equals("")){
        	
        	//imageLoader.DisplayImage(imageUrl, image);
        	Bitmap bimage=  getBitmapFromURL(urlImage);
        	image.setImageBitmap(bimage);
        }
        else image.setImageResource(R.drawable.m);
        
        MapView mapView = (MapView) findViewById(R.id.customeventmapview);
        mapView.setBuiltInZoomControls(true);
      
        Drawable marker=getResources().getDrawable(android.R.drawable.star_big_on);
        int markerWidth = marker.getIntrinsicWidth();
        int markerHeight = marker.getIntrinsicHeight();
        marker.setBounds(0, markerHeight, markerWidth, 0);
    
      
        MyItemizedOverlay myItemizedOverlay = new MyItemizedOverlay(marker);
        mapView.getOverlays().add(myItemizedOverlay);
//      30.268149,-97.742829
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
        
        pixButton = (ImageButton) findViewById(R.id.takePic);
        pixButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // Perform action on click
            	Intent intent1 = new Intent(getBaseContext(), TakePix.class);
            	Log.d("venue id ", venueID);
            	intent1.putExtra("VENUEID", venueID);
            	startActivity(intent1);
            }
        });
        
        p1_button = (Button) findViewById(R.id.customEventVenue);
        
        p1_button.setBackgroundColor(Color.LTGRAY);
        p1_button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
            	new CountDownTimer(450, 400) {

           	     public void onTick(long millisUntilFinished) {
           	    	p1_button.setBackgroundColor(Color.WHITE);
           	         Log.d("seconds remaining: ","" + millisUntilFinished / 1000);
           	     }

           	     public void onFinish() {
           	    	p1_button.setBackgroundColor(Color.LTGRAY);
           	    	 Log.d("done!","");
           	     }
           	  }.start();
                // Perform action on click
            	Intent intent1 = new Intent(getBaseContext(), VenueViewActivity.class);
            	Log.d("venue id ", venueID);
            	intent1.putExtra("VENUEID", venueID);
            	startActivity(intent1);
            }
        });
        
 
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
	public static Bitmap getBitmapFromURL(String src) {
        try {
            
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            
            return myBitmap;
        } catch (IOException e) {
            e.printStackTrace();
            Log.e("Exception",e.getMessage());
            return null;
        }
    }
	
	
	
}