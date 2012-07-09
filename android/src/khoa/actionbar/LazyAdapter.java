package khoa.actionbar;


import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.util.Log;

public class LazyAdapter extends BaseAdapter {
    
    private Activity activity;
    private String[] data;
    ArrayList<HashMap<String, String>> inboxList;
    private static LayoutInflater inflater=null;
    public ImageLoader imageLoader; 
    private String imageUrl;
    public LazyAdapter(Activity a, ArrayList<HashMap<String, String>> d) {
        activity = a;
        inboxList = new ArrayList<HashMap<String, String>>();
        inboxList=d;
        inflater = (LayoutInflater)activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        imageLoader=new ImageLoader(activity.getApplicationContext());
    }

    public int getCount() {
        return inboxList.size();
    }

    public Object getItem(int position) {
        return position;
    }

    public long getItemId(int position) {
        return position;
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
    
    public View getView(int position, View convertView, ViewGroup parent) {
        View vi=convertView;
        if(convertView==null)
            vi = inflater.inflate(R.layout.item, null);

        
        
        HashMap<String, String> map = new HashMap<String, String>();
        map = inboxList.get(position);
        
        //String urlImage = "http://static.independenttickets.com/common/events/69257_lg.jpg";
        
       
		

        TextView eventDesText=(TextView)vi.findViewById(R.id.eventDescription);
        String eventDes = map.get("TIME");
        eventDesText.setText(eventDes);
        
        TextView eventNameText=(TextView)vi.findViewById(R.id.eventName);
        String eventName = map.get("EVENTNAME");
        eventNameText.setText(eventName);
        
        TextView eventPriceText=(TextView)vi.findViewById(R.id.price);
        String eventPrice = map.get("PRICE");
        eventPriceText.setText(eventPrice);
        
        TextView eventVenueText=(TextView)vi.findViewById(R.id.location);
        String eventLot = map.get("EVENTLOCATION");
        eventVenueText.setText(eventLot);
        
        TextView eventDistText=(TextView)vi.findViewById(R.id.eventDist);
        String eventDist = map.get("DISTANCE");
        eventDistText.setText(eventDist);
        
        ImageView image=(ImageView)vi.findViewById(R.id.eventImage);
        imageUrl = map.get("IMAGEURL");
        if (!imageUrl.equals("")){
        	
        	imageLoader.DisplayImage(imageUrl, image);
        	
//        	Log.d("imageUrl ",imageUrl);
//        	Bitmap bimage=  getBitmapFromURL(imageUrl);
//        	image.setImageBitmap(bimage);
        }
        else {
        	image.setImageResource(R.drawable.m);
        }
       
       // imageLoader.DisplayImage(imageUrl, image);
        return vi;
    }
}