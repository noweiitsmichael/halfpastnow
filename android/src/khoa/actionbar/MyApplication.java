package khoa.actionbar;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.Application;

public class MyApplication extends Application {
	 private String myApplicationString;
	 private String priceString;
	 private String todayOrTomorrowString;
	 private String dayString;
	 private String distanceString;
	 private String priceStringS;
	 private String dayStringS;
	 private ArrayList<HashMap<String, String>> inboxList;
	 
	 
	      
	         public String getMyApplicationString() {
	             return myApplicationString;
	         }
	         
	         public void setMyApplicationString(String myApplicationString) {
	             this.myApplicationString = myApplicationString;
	        }    
	         public ArrayList<HashMap<String, String>> getList() {
	             return inboxList;
	         }
	         
	         public void setList(ArrayList<HashMap<String, String>> myApplicationString) {
	             this.inboxList = myApplicationString;
	        }   
	         public String getPriceString() {
	             return priceString;
	         }
	         
	         public void setPriceString(String price) {
	             this.priceString = price;
	        } 
	         public String getPriceStringS() {
	             return priceStringS;
	         }
	         
	         public void setPriceStringS(String price) {
	             this.priceStringS = price;
	        } 
	         public String getDayString() {
	             return dayString;
	         }
	         
	         public void setDayString(String day) {
	             this.dayString = day;
	        } 
	         public String getDayStringS() {
	             return dayStringS;
	         }
	         
	         public void setDayStringS(String day) {
	             this.dayStringS = day;
	        } 
	         public String getTodayOrTomorrowString() {
	             return todayOrTomorrowString;
	         }
	         
	         public void setTodayOrTomorrowString(String todayOrTomorrow) {
	             this.todayOrTomorrowString = todayOrTomorrow;
	        }
	         public String getDistanceString() {
	             return distanceString;
	         }
	         
	         public void setDistanceString(String distance) {
	             this.distanceString = distance;
	        }
}
