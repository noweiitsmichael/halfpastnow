package khoa.actionbar;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;

public class CustomOverlayItem extends OverlayItem {

	protected String mImageURL;
	protected String time;
	protected String location;
	protected String price;
	protected String EVENT_ID;
	protected String EVENTNAME;
	protected String DESCRIPTION;
	protected String ADD1;
	protected String ADD2;
	protected String LAT;
	protected String LONG;
	protected String VENUEID;
	protected String VENUENAME;
	protected String DISTANCE;
	
//	intent.putExtra("EVENT_ID", map.get("ID"));
//	intent.putExtra("EVENTNAME", map.get("EVENTNAME"));
//	intent.putExtra("TIME", map.get("TIME"));
//	intent.putExtra("DESCRIPTION", map.get("DESCRIPTION"));
//	intent.putExtra("IMAGEURL", map.get("IMAGEURL"));
//	intent.putExtra("PRICE", map.get("PRICE"));
//	intent.putExtra("ADD1", map.get("ADD1"));
//	intent.putExtra("ADD2", map.get("ADD2"));
//	intent.putExtra("LAT", map.get("LAT"));
//	intent.putExtra("LONG", map.get("LONG"));
//	intent.putExtra("VENUEID", map.get("VENUEID"));
//	intent.putExtra("VENUENAME", map.get("VENUENAME"));
	public CustomOverlayItem(GeoPoint point, String title, String snippet, String imageURL,String timeC,String locationC, String priceC,
			String EVENT_IDC, String EVENTNAMEC ,String DESCRIPTIONC ,String ADD1C,String ADD2C,String LATC ,String LONGC , 
			String VENUEIDC , String VENUENAMEC,String DISTANCEC) {
		super(point, title, snippet);
		mImageURL = imageURL;
		time = timeC;
		location = locationC;
		price = priceC;
		
		EVENT_ID =EVENT_IDC;
		EVENTNAME = EVENTNAMEC ;
		DESCRIPTION = DESCRIPTIONC;
		ADD1 = ADD1C ;
		ADD2 = ADD2C ;
		LAT = LATC ;
		LONG = LONGC;
		VENUEID = VENUEIDC ;
		VENUENAME = VENUENAMEC ;
		DISTANCE = DISTANCEC;
		
		
	}

	public String getEVENT_ID() {
		return EVENT_ID;
	}

	public void setEVENT_ID(String imageURL) {
		this.EVENT_ID = imageURL;
	}
	public String getDISTANCE() {
		return DISTANCE;
	}

	public void setDISTANCE(String imageURL) {
		this.DISTANCE = imageURL;
	}
	public String getEVENTNAME() {
		return EVENTNAME ;
	}

	public void setEVENTNAME(String imageURL) {
		this.EVENTNAME = imageURL;
	}
	public String getDESCRIPTION() {
		return DESCRIPTION;
	}

	public void setDESCRIPTION(String imageURL) {
		this.DESCRIPTION = imageURL;
	}
	public String getADD1() {
		return ADD1;
	}

	public void setADD1(String imageURL) {
		this.ADD1 = imageURL;
	}
	public String getADD2() {
		return ADD2 ;
	}

	public void setADD2(String imageURL) {
		this.ADD2 = imageURL;
	}
	public String getLAT() {
		return LAT ;
	}

	public void setLAT(String imageURL) {
		this.LAT = imageURL;
	}
	public String getLONG() {
		return LONG;
	}

	public void setLONG(String imageURL) {
		this.LONG = imageURL;
	}
	public String getVENUEID() {
		return VENUEID;
	}

	public void setVENUEID(String imageURL) {
		this.VENUEID = imageURL;
	}
	public String getVENUENAME() {
		return VENUENAME ;
	}
	public void setVENUENAME(String imageURL) {
		this.VENUENAME = imageURL;
	}
	
	public String getImageURL() {
		return mImageURL ;
	}
	public void setImageURL(String imageURL) {
		this.mImageURL = imageURL;
	}
	public String getTime() {
		return time;
	}

	public void setTime(String imageURL) {
		this.time = imageURL;
	}
	public String getLocation() {
		return location;
	}

	public void setLocation(String imageURL) {
		this.location = imageURL;
	}
	public String getPrice() {
		return price;
	}

	public void setPrice(String imageURL) {
		this.price = imageURL;
	}
}
