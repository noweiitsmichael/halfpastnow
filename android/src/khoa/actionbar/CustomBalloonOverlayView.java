package khoa.actionbar;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.maps.OverlayItem;
import com.readystatesoftware.mapviewballoons.BalloonOverlayView;
import com.readystatesoftware.mapviewballoons.R;

public class CustomBalloonOverlayView<Item extends OverlayItem> extends BalloonOverlayView<CustomOverlayItem> {

	private TextView title;
	private TextView snippet;
	
	private TextView price;
	private TextView time;
	
	private ImageView image;
	private TextView dist;
	public ImageLoader imageLoader; 
	
	public CustomBalloonOverlayView(Context context, int balloonBottomOffset) {
		super(context, balloonBottomOffset);
	}
	
	@Override
	protected void setupView(Context context, final ViewGroup parent) {
		
		// inflate our custom layout into parent
		LayoutInflater inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View v = inflater.inflate(R.layout.balloon_overlay_hpn, parent);
		
		// setup our fields
		title = (TextView) v.findViewById(R.id.balloon_item_title);
		snippet = (TextView) v.findViewById(R.id.balloon_item_snippet);
		image = (ImageView) v.findViewById(R.id.balloon_item_image);
		imageLoader=new ImageLoader(context);
		price = (TextView) v.findViewById(R.id.mapPrice);
		time = (TextView) v.findViewById(R.id.mapTime); 
		dist = (TextView) v.findViewById(R.id.mapDist);
	}

	@Override
	protected void setBalloonData(CustomOverlayItem item, ViewGroup parent) {
		
		// map our custom item data to fields
		title.setText(item.getTitle());
		snippet.setText(item.getSnippet());
		
		// get remote image from network.
		// bitmap results would normally be cached, but this is good enough for demo purpose.
		
		 String imageUrl =item.getImageURL();
		 String time1 = item.getTime();
		 String price1 = item.getPrice();
		 String dist1 = item.getDISTANCE();
		 price.setText(price1);
		 time.setText(time1);
		 dist.setText(dist1);
		 Log.d("Image URL ------", " "+imageUrl);
		 
		
	        if (!imageUrl.equals("")){
	        	
	        	imageLoader.DisplayImage(imageUrl, image);
	        	}
	        else  image.setImageResource(R.drawable.icon);
	       
		
		
		
		
	}

	private class FetchImageTask extends AsyncTask<String, Integer, Bitmap> {
	    @Override
	    protected Bitmap doInBackground(String... arg0) {
	    	Bitmap b = null;
	    	try {
				 b = BitmapFactory.decodeStream((InputStream) new URL(arg0[0]).getContent());
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} 
	        return b;
	    }	
	}
	
}
