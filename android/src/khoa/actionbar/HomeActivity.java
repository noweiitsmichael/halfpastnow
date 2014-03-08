package khoa.actionbar;


import android.os.Bundle;
import android.util.Log;
import khoa.actionbar.MyApplication;

public class HomeActivity extends ActionBarAppActivity
{
	
	public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
       
        MyApplication appState = ((MyApplication)getApplicationContext());
        //Set the textview's text using the app's string
        Log.d("the String is "," "+appState.getMyApplicationString());
        
    }

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
}
