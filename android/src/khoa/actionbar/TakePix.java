package khoa.actionbar;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URL;
import java.util.Date;
import java.util.List;


import com.readystatesoftware.mapviewballoons.R;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.ShutterCallback;
import android.hardware.Camera.Size;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.MediaStore.Images;
import android.provider.MediaStore.Images.Media;
import android.provider.MediaStore.MediaColumns;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Toast;


import com.amazonaws.auth.BasicAWSCredentials;


import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.ResponseHeaderOverrides;


public class TakePix extends Activity implements SurfaceHolder.Callback {
	
	Camera camera;
	SurfaceView surfaceView;
	SurfaceHolder surfaceHolder;
	boolean previewing = false;
	LayoutInflater controlInflater = null;
	private AmazonS3Client s3Client = new AmazonS3Client( new BasicAWSCredentials( Constants.ACCESS_KEY_ID, Constants.SECRET_KEY ) );
	
	
	ImageButton buttonTakePicture;
	
	final int RESULT_SAVEIMAGE = 0;
	
	public  void onCreate(final Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.camera);
setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        
        getWindow().setFormat(PixelFormat.UNKNOWN);
        surfaceView = (SurfaceView)findViewById(R.id.camerapreview);
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
        surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        
        controlInflater = LayoutInflater.from(getBaseContext());
        View viewControl = controlInflater.inflate(R.layout.control, null);
        LayoutParams layoutParamsControl 
        	= new LayoutParams(LayoutParams.FILL_PARENT, 
        	LayoutParams.FILL_PARENT);
        this.addContentView(viewControl, layoutParamsControl);
        
        buttonTakePicture = (ImageButton)findViewById(R.id.takePixBtn);
        buttonTakePicture.setOnClickListener(new Button.OnClickListener(){

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				camera.takePicture(myShutterCallback, 
						myPictureCallback_RAW, myPictureCallback_JPG);
			}});
        
        LinearLayout layoutBackground = (LinearLayout)findViewById(R.id.background);
        layoutBackground.setOnClickListener(new LinearLayout.OnClickListener(){

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

				buttonTakePicture.setEnabled(false);
				camera.autoFocus(myAutoFocusCallback);
			}});
    }
	
	 AutoFocusCallback myAutoFocusCallback = new AutoFocusCallback(){

			@Override
			public void onAutoFocus(boolean arg0, Camera arg1) {
				// TODO Auto-generated method stub
				buttonTakePicture.setEnabled(true);
			}};
	    
	    ShutterCallback myShutterCallback = new ShutterCallback(){

			@Override
			public void onShutter() {
				// TODO Auto-generated method stub
				
			}};
			
		PictureCallback myPictureCallback_RAW = new PictureCallback(){

			@Override
			public void onPictureTaken(byte[] arg0, Camera arg1) {
				// TODO Auto-generated method stub
				
			}};
			
		PictureCallback myPictureCallback_JPG = new PictureCallback(){

			@Override
			public void onPictureTaken(byte[] arg0, Camera arg1) {
				// TODO Auto-generated method stub
				/*Bitmap bitmapPicture 
					= BitmapFactory.decodeByteArray(arg0, 0, arg0.length);	*/
				
				Uri uriTarget = null;
				try {
					uriTarget = getContentResolver().insert(Media.EXTERNAL_CONTENT_URI, saveToFileAndUri());
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}

				OutputStream imageFileOS;
				try {
					imageFileOS = getContentResolver().openOutputStream(uriTarget);
					imageFileOS.write(arg0);
					imageFileOS.flush();
					imageFileOS.close();
					
					Toast.makeText(TakePix.this, 
							"Image saved: " + uriTarget.getPath().toString(), 
							Toast.LENGTH_LONG).show();
					
					decodeFile(uriTarget);
					
					
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				camera.startPreview();
			}};

	private ContentValues saveToFileAndUri() throws Exception{
		        long currentTime = System.currentTimeMillis();
		        String fileName = "Khoa_Le_" + currentTime+".jpg";
		        File extBaseDir = Environment.getExternalStorageDirectory();
		        File file = new File(extBaseDir.getAbsoluteFile()+"/MY_DIRECTORY");
		        if(!file.exists()){
		            if(!file.mkdirs()){
		                throw new Exception("Could not create directories, "+file.getAbsolutePath());
		            }
		        }
		        String filePath = file.getAbsolutePath()+"/"+fileName;
		        ;

		        long size = new File(filePath).length();

		        ContentValues values = new ContentValues(6);
		        values.put(Images.Media.TITLE, fileName);

		        // That filename is what will be handed to Gmail when a user shares a
		        // photo. Gmail gets the name of the picture attachment from the
		        // "DISPLAY_NAME" field.
		        values.put(Images.Media.DISPLAY_NAME, fileName);
		        values.put(Images.Media.DATE_ADDED, currentTime);
		        values.put(Images.Media.MIME_TYPE, "image/jpeg");
		        values.put(Images.Media.ORIENTATION, 0);
		        values.put(Images.Media.DATA, filePath);
		        values.put(Images.Media.SIZE, size);

		        return values;

		    }
    
    public void onSearch(View v)
    {
    	EditText mEdit   = (EditText)findViewById(R.id.input_text_main);
    	
    	Intent intent = new Intent(getBaseContext(), FindActivity.class);
    	intent.putExtra("KEY", mEdit.getText().toString());
        startActivity (intent);
    	
    }
    public void take(View v)
    {
    	// TODO Auto-generated method stub
    	
    	Camera.Parameters params = camera.getParameters();
    	List<Size> sizes = params.getSupportedPictureSizes();
    	// See which sizes the camera supports and choose one of those
    	
    	
		camera.takePicture(myShutterCallback, 
				myPictureCallback_RAW, myPictureCallback_JPG);
    	
    }
    
    private String getRealPathFromURI(Uri contentURI) {
        Cursor cursor = getContentResolver().query(contentURI, null, null, null, null); 
        cursor.moveToFirst(); 
        int idx = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA); 
        return cursor.getString(idx); 
    }
    
    private Bitmap decodeFile(Uri urii){
    	File f = null;
        try {
            //Decode image size
            BitmapFactory.Options o = new BitmapFactory.Options();
            o.inJustDecodeBounds = true;
            
            
            f = new File(getRealPathFromURI(urii));
            BitmapFactory.decodeStream(new FileInputStream(f),null,o);

            //The new size we want to scale to
            final int REQUIRED_SIZE=3;

            //Find the correct scale value. It should be the power of 2.
            int scale=1;
            while(o.outWidth/scale/2>=REQUIRED_SIZE && o.outHeight/scale/2>=REQUIRED_SIZE)
                scale*=2;

            //Decode with inSampleSize
            BitmapFactory.Options o2 = new BitmapFactory.Options();
            o2.inSampleSize=scale;
            
            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
            Bitmap _bitmapScaled = BitmapFactory.decodeStream(new FileInputStream(f), null, o2);
            _bitmapScaled.compress(Bitmap.CompressFormat.JPEG, 40, bytes);

            //you can create a new file name "test.jpg" in sdcard folder.
            File file = new File(Environment.getExternalStorageDirectory()
                                    + File.separator + "test.jpg");
            try {
				file.createNewFile();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            //write the bytes in file
            FileOutputStream fo = new FileOutputStream(f);
            fo.write(bytes.toByteArray());
            
            FileInputStream bm = new FileInputStream(f);
            
            ///////////////
            // THe file location of the image selected.
//               Uri selectedImage = imageReturnedIntent.getData();
               String[] filePathColumn = {MediaStore.Images.Media.DATA};
              
               Cursor cursor = getContentResolver().query(urii, filePathColumn, null, null, null);
               cursor.moveToFirst();

               int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
               String filePath = cursor.getString(columnIndex);
               Log.d("Path file ",""+filePath);
               cursor.close();

               // Put the image data into S3.
               try {
               	s3Client.createBucket(  Constants.getPictureBucket() );
               //	s3Client.createBucket( "venue" );
               	
               //	PutObjectRequest por = new PutObjectRequest( Constants.getPictureBucket(), Constants.PICTURE_NAME, f );  // Content type is determined by file extension.
            	PutObjectRequest por = new PutObjectRequest(  Constants.getPictureBucket(), "veneu/event.jpg", f ); 
               	s3Client.putObject( por );
               }
               catch ( Exception exception ) {
               	
               }
               
             /////////////  
              
            return BitmapFactory.decodeStream(bm, null, o2);
        } catch (FileNotFoundException e) {} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
   
        return null;
    }
    
    public void onSearchView(View v)
    {
    	startActivity (new Intent(getApplicationContext(), ReloadMapActivity.class));
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
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		// TODO Auto-generated method stub
		if(previewing){
			camera.stopPreview();
			previewing = false;
		}
		
		if (camera != null){
			try {
				camera.setPreviewDisplay(surfaceHolder);
				camera.startPreview();
				previewing = true;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		camera = Camera.open();
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		camera.stopPreview();
		camera.release();
		camera = null;
		previewing = false;
	}

}
