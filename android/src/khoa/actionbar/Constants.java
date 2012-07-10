package khoa.actionbar;

public class Constants {
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // This sample App is for demonstration purposes only.
    // It is not secure to embed your credentials into source code.
    // Please read the following article for getting credentials
    // to devices securely.
    // http://aws.amazon.com/articles/Mobile/4611615499399490
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	public static final String ACCESS_KEY_ID = "AKIAJ7DK3A7EKGE7CEQA";
	public static final String SECRET_KEY = "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";
	
	public static final String PICTURE_BUCKET = "khoa";
	public static final String PICTURE_NAME = "NameOfThePicture";
	
	
	public static String getPictureBucket() {
		return ("my-unique-name" + ACCESS_KEY_ID + PICTURE_BUCKET).toLowerCase();
	}
	
}
