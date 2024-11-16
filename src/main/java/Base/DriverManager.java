package Base;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import utilities.PropertyHandler;

import java.net.MalformedURLException;
import java.net.URL;

public class DriverManager {

    private static ThreadLocal<WebDriver> threadLocalDriver= new ThreadLocal<>();
    public void initDriver() {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--disable-gpu");
        options.addArguments("--remote-allow-origins=*");
        WebDriver driver = new ChromeDriver(options);
 
    }

    public static ChromeOptions getChromeOptions(){
        ChromeOptions chromeOptions = new ChromeOptions();
//        chromeOptions.addArguments("--no-sandbox");
//        chromeOptions.addArguments("--disable-dev-shm-usage");
//        chromeOptions.addArguments("--headless");
        return chromeOptions;
    }

    private static String getGridUrl(){
        String gridUrl=null;
        String gridUrlProp=PropertyHandler.getProperty(PropertyHandler.SELGRID_URL_KEY);
        if(gridUrlProp!=null && !gridUrlProp.isEmpty()){
            gridUrl =  String.format("http://%s:4444",gridUrlProp);
        }
        return gridUrl;
    }

    public static WebDriver getDriver(){
        return threadLocalDriver.get();
    }

    public static void quitDriver(){
        threadLocalDriver.get().quit();
        threadLocalDriver.remove();
    }

}
