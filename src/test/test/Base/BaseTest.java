package Base;

import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import utilities.PropertyHandler;

public class BaseTest {

    protected String url;

    @BeforeSuite
    public void initSuite(){
        String executionMode = PropertyHandler.getProperty(PropertyHandler.SELGRID_URL_KEY).isEmpty() ? "Local Execution" : "Grid Execution";
        System.out.println(executionMode);
    }

    @BeforeMethod
    public void init(){
        DriverManager driverManager = new DriverManager();
        driverManager.initDriver();
        url = PropertyHandler.getProperty("url");
        DriverManager.getDriver().get(url);
    }

    @AfterMethod
    public void tearDown(){
        DriverManager.quitDriver();
    }

}
