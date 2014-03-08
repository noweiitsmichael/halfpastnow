package khoa.actionbar;


import java.io.IOException;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;

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

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;

import android.app.Activity;
import android.app.Dialog;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

public abstract class ActionBarAppActivity extends MapActivity  implements OnTouchListener
{
    /** Called when the activity is first created. */
	ImageButton   mButton;
	EditText mEdit;
	JSONParser jsonParser = new JSONParser();
	private LinearLayout getLinearLayout;

	ArrayList<HashMap<String, String>> inboxList;

	// products JSONArray
	JSONArray inbox = null;
	@Override
    public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        //setContentView(R.layout.main);
        //add list view here
        inboxList = new ArrayList<HashMap<String, String>>();
        getWindow().setSoftInputMode( WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        
        this.getWindow().setSoftInputMode(
        		WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        		requestWindowFeature(Window.FEATURE_NO_TITLE);
        		setContentView(R.layout.main);
        		mEdit = (EditText)findViewById(R.id.input_text_main);
        		getLinearLayout = (LinearLayout)findViewById(R.id.overview);
        		getLinearLayout.setOnTouchListener(this);
        
       
        
    }
   
    public boolean onTouch(View v, MotionEvent event) {
//    if(v==getLinearLayout){
//    	 getWindow().setSoftInputMode( WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
//    return true;
//    }
//    getWindow().setSoftInputMode( WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
    	Log.d("Inbox JSON: ", "");
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
    	
    	Intent intent = new Intent(getApplicationContext(), FindActivity.class);
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
}