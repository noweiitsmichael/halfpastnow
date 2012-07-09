package khoa.actionbar;
import com.google.android.maps.MapActivity;
import android.os.CountDownTimer;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;

public class FilterActivity  extends ActionBarAppActivity {
	private Button day1;
	private Button day2;
	private Button day3;
	private Button day4;
	private Button day5;
	private Button day6;
	private Button day7;
	private Button todayBtn;
	private Button tomorrowBtn;
	private Button price0;
	private Button price1;
	private Button price2;
	private Button price3;
	private Button price4;
	private Button dist0;
	private Button dist1;
	private Button dist2;
	private Button dist3;
	private String dayString;
	private String priceString;
	private String distanceString;
	private String todayTomorrowString;
	private String dayStringS;
	private String priceStringS;
	private String distanceStringS;
	private String todayTomorrowStringS;
	private Button resetBtn;
	
	EditText mEdit;
	public String distance;
	
	private LinearLayout getLinearLayout;
	public  void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.filter);
        
        MyApplication appState = ((MyApplication)getApplicationContext());
        appState.setMyApplicationString("KHoa is here");
        		
        		mEdit = (EditText)findViewById(R.id.input_text_main);
        		getLinearLayout = (LinearLayout)findViewById(R.id.overview);
        
		
		            //Set the app string on our app instance
        String days =  appState.getDayStringS();
        String prices = appState.getPriceStringS();
        String dist = appState.getDistanceString();
        String tOt = appState.getTodayOrTomorrowString();
        Log.d("days ",""+days );
        Log.d("prices ",""+prices );
        Log.d("dist ",""+dist );
        Log.d("tOt",""+tOt );
        
       
        
        day1 = (Button)findViewById(R.id.button1);
        day2 = (Button)findViewById(R.id.button2);
        day3 = (Button)findViewById(R.id.button3);
        day4 = (Button)findViewById(R.id.button4);
        day5 = (Button)findViewById(R.id.button5);
        day6 = (Button)findViewById(R.id.button6);
        day7 = (Button)findViewById(R.id.button7);
        
        
        todayBtn = (Button)findViewById(R.id.todayBtn);
        tomorrowBtn = (Button)findViewById(R.id.tomorrowBtn);
        resetBtn = (Button)findViewById(R.id.resetBtn);
        price0 = (Button)findViewById(R.id.price0);
        price1 = (Button)findViewById(R.id.price1);
        price2 = (Button)findViewById(R.id.price2);
        price3 = (Button)findViewById(R.id.price3);
        price4 = (Button)findViewById(R.id.price4);
       
        dist0 = (Button)findViewById(R.id.dist0);
        dist1 = (Button)findViewById(R.id.dist1);
        dist2 = (Button)findViewById(R.id.dist2);
        dist3 = (Button)findViewById(R.id.dist3);
        day1.setSelected(false);
        day1.setBackgroundColor(Color.WHITE);
        day2.setSelected(false);
        day2.setBackgroundColor(Color.WHITE);
        day3.setSelected(false);
        day3.setBackgroundColor(Color.WHITE);
        day4.setSelected(false);
        day4.setBackgroundColor(Color.WHITE);
        day5.setSelected(false);
        day5.setBackgroundColor(Color.WHITE);
        day6.setSelected(false);
        day6.setBackgroundColor(Color.WHITE);
        day7.setSelected(false);
        day7.setBackgroundColor(Color.WHITE);
        price0.setSelected(false);
        price0.setBackgroundColor(Color.WHITE);
        price1.setSelected(false);
        price1.setBackgroundColor(Color.WHITE);
        price2.setSelected(false);
        price2.setBackgroundColor(Color.WHITE);
        price3.setSelected(false);
        price3.setBackgroundColor(Color.WHITE);
        price4.setSelected(false);
        price4.setBackgroundColor(Color.WHITE);
        dist0.setSelected(false);
        dist0.setBackgroundColor(Color.WHITE);
        dist1.setSelected(false);
        dist1.setBackgroundColor(Color.WHITE);
        dist2.setSelected(false);
        dist2.setBackgroundColor(Color.WHITE);
        dist3.setSelected(false);
        dist3.setBackgroundColor(Color.WHITE);
        todayBtn.setSelected(false);
        todayBtn.setBackgroundColor(Color.WHITE);
        tomorrowBtn.setSelected(false);
        tomorrowBtn.setBackgroundColor(Color.WHITE);
        
        if(days!=null){
        	Log.d("it not null"," ");
        	if(days.equals("")){
        		 	day1.setSelected(false);
        	        day1.setBackgroundColor(Color.WHITE);
        	        day2.setSelected(false);
        	        day2.setBackgroundColor(Color.WHITE);
        	        day3.setSelected(false);
        	        day3.setBackgroundColor(Color.WHITE);
        	        day4.setSelected(false);
        	        day4.setBackgroundColor(Color.WHITE);
        	        day5.setSelected(false);
        	        day5.setBackgroundColor(Color.WHITE);
        	        day6.setSelected(false);
        	        day6.setBackgroundColor(Color.WHITE);
        	        day7.setSelected(false);
        	        day7.setBackgroundColor(Color.WHITE);
        	}
        	for (int i=0;i<days.length();i++){
        		char c = days.charAt(i);
        		if (c=='0'){
        			day1.setSelected(true);
        	        day1.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='1'){
        			day2.setSelected(true);
        	        day2.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='2'){
        			day3.setSelected(true);
        	        day3.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='3'){
        			day4.setSelected(true);
        	        day4.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='4'){
        			day5.setSelected(true);
        	        day5.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='5'){
        			day6.setSelected(true);
        	        day6.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='6'){
        			day7.setSelected(true);
        	        day7.setBackgroundColor(Color.GRAY);
        		}
        		
        	}
        }
       
        if(prices!=null){
        	Log.d("it not null"," ");
        	if(prices.equals("")){
        		price0.setSelected(false);
                price0.setBackgroundColor(Color.WHITE);
                price1.setSelected(false);
                price1.setBackgroundColor(Color.WHITE);
                price2.setSelected(false);
                price2.setBackgroundColor(Color.WHITE);
                price3.setSelected(false);
                price3.setBackgroundColor(Color.WHITE);
                price4.setSelected(false);
                price4.setBackgroundColor(Color.WHITE);
        	}
        	for (int i=0;i<prices.length();i++){
        		char c = prices.charAt(i);
        		if (c=='0'){
        			price0.setSelected(true);
        			price0.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='1'){
        			price1.setSelected(true);
        			price1.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='2'){
        			price2.setSelected(true);
        			price2.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='3'){
        			price3.setSelected(true);
        			price3.setBackgroundColor(Color.GRAY);
        		}
        		if (c=='4'){
        			price4.setSelected(true);
        			price4.setBackgroundColor(Color.GRAY);
        		}
        		
        	}
        }
        
        if(dist!=null){
        	Log.d("it not null"," ");
        	if(dist.equals("")){
        		dist0.setSelected(false);
                dist0.setBackgroundColor(Color.WHITE);
                dist1.setSelected(false);
                dist1.setBackgroundColor(Color.WHITE);
                dist2.setSelected(false);
                dist2.setBackgroundColor(Color.WHITE);
                dist3.setSelected(false);
                dist3.setBackgroundColor(Color.WHITE);
                
        	}
        	if(dist.equals("0")){
        		dist0.setSelected(true);
                dist0.setBackgroundColor(Color.GRAY);
        	}
        	if(dist.equals("1")){
        		dist1.setSelected(true);
                dist1.setBackgroundColor(Color.GRAY);
        	}
        	if(dist.equals("2")){
        		dist2.setSelected(true);
                dist2.setBackgroundColor(Color.GRAY);
        	}
        	if(dist.equals("3")){
        		dist3.setSelected(true);
                dist3.setBackgroundColor(Color.GRAY);
        	}
        }
        if(tOt!=null){
        	Log.d("it not null"," ");
        	if(tOt.equals("")){
        		 	todayBtn.setSelected(false);
        	        todayBtn.setBackgroundColor(Color.WHITE);
        	        tomorrowBtn.setSelected(false);
        	        tomorrowBtn.setBackgroundColor(Color.WHITE);
        	        
                
        	}
        	if(tOt.equals("0")){
        		todayBtn.setSelected(true);
    	        todayBtn.setBackgroundColor(Color.GRAY);
        	}
        	if(tOt.equals("1")){
        		tomorrowBtn.setSelected(true);
     	        tomorrowBtn.setBackgroundColor(Color.GRAY);
        	}
        	
        }
       
        
        
        
        
        
        
        
        
        resetBtn.setSelected(false);
        resetBtn.setBackgroundColor(Color.WHITE);
        
        resetBtn.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                    	
                    	new CountDownTimer(450, 400) {

                    	     public void onTick(long millisUntilFinished) {
                    	    	 resetBtn.setBackgroundColor(Color.GRAY);
                    	         Log.d("seconds remaining: ","" + millisUntilFinished / 1000);
                    	     }

                    	     public void onFinish() {
                    	    	 resetBtn.setBackgroundColor(Color.WHITE);
                    	    	 Log.d("done!","");
                    	     }
                    	  }.start();
                    	  day1.setSelected(false);
                          day1.setBackgroundColor(Color.WHITE);
                          day2.setSelected(false);
                          day2.setBackgroundColor(Color.WHITE);
                          day3.setSelected(false);
                          day3.setBackgroundColor(Color.WHITE);
                          day4.setSelected(false);
                          day4.setBackgroundColor(Color.WHITE);
                          day5.setSelected(false);
                          day5.setBackgroundColor(Color.WHITE);
                          day6.setSelected(false);
                          day6.setBackgroundColor(Color.WHITE);
                          day7.setSelected(false);
                          day7.setBackgroundColor(Color.WHITE);
                          todayBtn.setSelected(false);
                          todayBtn.setBackgroundColor(Color.WHITE);
                          tomorrowBtn.setSelected(false);
                          tomorrowBtn.setBackgroundColor(Color.WHITE);
                          price0.setSelected(false);
                          price0.setBackgroundColor(Color.WHITE);
                          price1.setSelected(false);
                          price1.setBackgroundColor(Color.WHITE);
                          price2.setSelected(false);
                          price2.setBackgroundColor(Color.WHITE);
                          price3.setSelected(false);
                          price3.setBackgroundColor(Color.WHITE);
                          price4.setSelected(false);
                          price4.setBackgroundColor(Color.WHITE);
                          dist0.setSelected(false);
                          dist0.setBackgroundColor(Color.WHITE);
                          dist1.setSelected(false);
                          dist1.setBackgroundColor(Color.WHITE);
                          dist2.setSelected(false);
                          dist2.setBackgroundColor(Color.WHITE);
                          dist3.setSelected(false);
                          dist3.setBackgroundColor(Color.WHITE);
                          dayString="";
                      	  priceString="";
                      	  dayStringS="";
                    	  priceStringS="";
                      	  distanceString="";
                      	  todayTomorrowString="";
                      	  resetFilter();
						
                    }
                
                });
                

        price0.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button price0 ", "cliced");
                        if (price0.isSelected()){
                        	price0.setSelected(false);
                        	price0.setBackgroundColor(Color.WHITE);
                        } else {
                        	price0.setSelected(true);
                        	price0.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        price1.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button price1 ", "cliced");
                        if (price1.isSelected()){
                        	price1.setSelected(false);
                        	price1.setBackgroundColor(Color.WHITE);
                        } else {
                        	price1.setSelected(true);
                        	price1.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        price2.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button price2 ", "cliced");
                        if (price2.isSelected()){
                        	price2.setSelected(false);
                        	price2.setBackgroundColor(Color.WHITE);
                        } else {
                        	price2.setSelected(true);
                        	price2.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        price3.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button price3 ", "cliced");
                        if (price3.isSelected()){
                        	price3.setSelected(false);
                        	price3.setBackgroundColor(Color.WHITE);
                        } else {
                        	price3.setSelected(true);
                        	price3.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        price4.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button price4 ", "cliced");
                        if (price4.isSelected()){
                        	price4.setSelected(false);
                        	price4.setBackgroundColor(Color.WHITE);
                        } else {
                        	price4.setSelected(true);
                        	price4.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        
        day1.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 1 ", "cliced");
                        if (day1.isSelected()){
                        	day1.setSelected(false);
                            day1.setBackgroundColor(Color.WHITE);
                        } else {
                        	day1.setSelected(true);
                        	day1.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day2.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 2 ", "cliced");
                        if (day2.isSelected()){
                        	day2.setSelected(false);
                            day2.setBackgroundColor(Color.WHITE);
                        } else {
                        	day2.setSelected(true);
                        	day2.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day3.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 3 ", "cliced");
                        if (day3.isSelected()){
                        	day3.setSelected(false);
                            day3.setBackgroundColor(Color.WHITE);
                        } else {
                        	day3.setSelected(true);
                        	day3.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day4.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 4 ", "cliced");
                        if (day4.isSelected()){
                        	day4.setSelected(false);
                            day4.setBackgroundColor(Color.WHITE);
                        } else {
                        	day4.setSelected(true);
                        	day4.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day5.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 5 ", "cliced");
                        if (day5.isSelected()){
                        	day5.setSelected(false);
                            day5.setBackgroundColor(Color.WHITE);
                        } else {
                        	day5.setSelected(true);
                        	day5.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day6.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 6 ", "cliced");
                        if (day6.isSelected()){
                        	day6.setSelected(false);
                            day6.setBackgroundColor(Color.WHITE);
                        } else {
                        	day6.setSelected(true);
                        	day6.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        day7.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button 7 ", "cliced");
                        if (day7.isSelected()){
                        	day7.setSelected(false);
                            day7.setBackgroundColor(Color.WHITE);
                        } else {
                        	day7.setSelected(true);
                        	day7.setBackgroundColor(Color.GRAY);
                        }
                        updateFilter();
                    }
                });
        
        todayBtn.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button todayBtn ", "cliced");
                        if (todayBtn.isSelected()){
                        	todayBtn.setSelected(false);
                        	todayBtn.setBackgroundColor(Color.WHITE);
                        } else {
                        	todayBtn.setSelected(true);
                        	todayBtn.setBackgroundColor(Color.GRAY);
                        	tomorrowBtn.setSelected(false);
                        	tomorrowBtn.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
        tomorrowBtn.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button tomorrowBtn ", "cliced");
                        if (tomorrowBtn.isSelected()){
                        	tomorrowBtn.setSelected(false);
                        	tomorrowBtn.setBackgroundColor(Color.WHITE);
                        } else {
                        	tomorrowBtn.setSelected(true);
                        	tomorrowBtn.setBackgroundColor(Color.GRAY);
                        	todayBtn.setSelected(false);
                        	todayBtn.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
        dist0.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button todayBtn ", "cliced");
                        if (dist0.isSelected()){
                        	dist0.setSelected(false);
                        	dist0.setBackgroundColor(Color.WHITE);
                        } else {
                        	dist0.setSelected(true);
                        	dist0.setBackgroundColor(Color.GRAY);
                        	dist1.setSelected(false);
                        	dist1.setBackgroundColor(Color.WHITE);
                        	dist2.setSelected(false);
                        	dist2.setBackgroundColor(Color.WHITE);
                        	dist3.setSelected(false);
                        	dist3.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
      
        dist1.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button todayBtn ", "cliced");
                        if (dist1.isSelected()){
                        	dist1.setSelected(false);
                        	dist1.setBackgroundColor(Color.WHITE);
                        } else {
                        	dist1.setSelected(true);
                        	dist1.setBackgroundColor(Color.GRAY);
                        	dist0.setSelected(false);
                        	dist0.setBackgroundColor(Color.WHITE);
                        	dist2.setSelected(false);
                        	dist2.setBackgroundColor(Color.WHITE);
                        	dist3.setSelected(false);
                        	dist3.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
        dist2.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button todayBtn ", "cliced");
                        if (dist2.isSelected()){
                        	dist2.setSelected(false);
                        	dist2.setBackgroundColor(Color.WHITE);
                        } else {
                        	dist2.setSelected(true);
                        	dist2.setBackgroundColor(Color.GRAY);
                        	dist1.setSelected(false);
                        	dist1.setBackgroundColor(Color.WHITE);
                        	dist0.setSelected(false);
                        	dist0.setBackgroundColor(Color.WHITE);
                        	dist3.setSelected(false);
                        	dist3.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
        dist3.setOnClickListener(
                new View.OnClickListener()
                {
                    public void onClick(View view)
                    {
                        Log.v("Button todayBtn ", "cliced");
                        if (dist3.isSelected()){
                        	dist3.setSelected(false);
                        	dist3.setBackgroundColor(Color.WHITE);
                        } else {
                        	dist3.setSelected(true);
                        	dist3.setBackgroundColor(Color.GRAY);
                        	dist1.setSelected(false);
                        	dist1.setBackgroundColor(Color.WHITE);
                        	dist0.setSelected(false);
                        	dist0.setBackgroundColor(Color.WHITE);
                        	dist2.setSelected(false);
                        	dist2.setBackgroundColor(Color.WHITE);
                        }
                        updateFilter();
                    }
                });
        
    }
	
	public void resetFilter()
	{
		MyApplication appState = ((MyApplication)getApplicationContext());
        appState.setPriceString(priceString);
        appState.setDayString(dayString);
        appState.setDistanceString(distanceString);
        appState.setTodayOrTomorrowString(todayTomorrowString);
        appState.setPriceStringS(priceStringS);
        appState.setDayStringS(dayStringS);
	}

	public void updateFilter()
	{
		dayString = "";
		dayStringS = "";
		
		if(day1.isSelected()){
			dayStringS = dayStringS + "0";
			if (dayString.equals(""))dayString = dayString + "0";
			else dayString = dayString + ",0";
		}
		if(day2.isSelected()){
			dayStringS = dayStringS + "1";
			if (dayString.equals(""))dayString = dayString + "1";
			else dayString = dayString + ",1";
		}
		if(day3.isSelected()){
			dayStringS = dayStringS + "2";
			if (dayString.equals(""))dayString = dayString + "2";
			else dayString = dayString + ",2";
		}
		if(day4.isSelected()){
			dayStringS = dayStringS + "3";
			if (dayString.equals(""))dayString = dayString + "3";
			else dayString = dayString + ",3";
		}
		if(day5.isSelected()){
			dayStringS = dayStringS + "4";
			if (dayString.equals(""))dayString = dayString + "4";
			else dayString = dayString + ",4";
		}
		if(day6.isSelected()){
			dayStringS = dayStringS + "5";
			if (dayString.equals(""))dayString = dayString + "5";
			else dayString = dayString + ",5";
		}
		if(day7.isSelected()){
			dayStringS = dayStringS + "6";
			if (dayString.equals(""))dayString = dayString + "6";
			else dayString = dayString + ",6";
		}
		priceString="";
		priceStringS="";
		if(price1.isSelected()){
			priceStringS = priceStringS + "1";
			if (priceString.equals(""))priceString = priceString + "1";
			else priceString = priceString + ",1";
		}
		if(price0.isSelected()){
			priceStringS = priceStringS + "0";
			if (priceString.equals(""))priceString = priceString + "0";
			else priceString = priceString + ",0";
		}
		if(price2.isSelected()){
			priceStringS = priceStringS + "2";
			if (priceString.equals(""))priceString = priceString + "2";
			else priceString = priceString + ",2";
		}
		if(price3.isSelected()){
			priceStringS = priceStringS + "3";
			if (priceString.equals(""))priceString = priceString + "3";
			else priceString = priceString + ",3";
		}
		if(price4.isSelected()){
			priceStringS = priceStringS + "4";
			if (priceString.equals(""))priceString = priceString + "4";
			else priceString = priceString + ",4";
		}
		distanceString ="";
		
		
		if(dist0.isSelected()){
			distanceString = "0";
			
		}
		if(dist1.isSelected()){
			
			distanceString = "1";
		}
		if(dist2.isSelected()){
			distanceString = "2";
		}
		if(dist3.isSelected()){
			distanceString = "3";
		}
		todayTomorrowString="";
		if(todayBtn.isSelected()){
			todayTomorrowString = "0";
		}
		if(tomorrowBtn.isSelected()){
			todayTomorrowString = "1";
		}
		Log.d("Days "," "+ dayString);
		Log.d("prices "," "+priceString);
		Log.d("Distance "," "+ distanceString);
		Log.d("today/tomorrow "," "+todayTomorrowString);
		MyApplication appState = ((MyApplication)getApplicationContext());
        appState.setPriceString(priceString);
        appState.setDayString(dayString);
        appState.setDistanceString(distanceString);
        appState.setTodayOrTomorrowString(todayTomorrowString);
        
        appState.setPriceStringS(priceStringS);
        appState.setDayStringS(dayStringS);

		
		
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
	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}

}
