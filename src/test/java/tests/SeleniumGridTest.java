package tests;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testng.annotations.Test;
import java.time.Duration;
import java.net.URL;

public class SeleniumGridTest {
    @Test
    public void testSeleniumGrid() throws Exception {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--no-sandbox");
        options.addArguments("--headless");
        
        // Get the Selenium Grid URL from environment or use localhost (port-forwarded)
        String gridHost = System.getenv("SELENIUM_GRID_HOST");
        if (gridHost == null || gridHost.isEmpty()) {
            gridHost = "localhost";
        }
        String gridUrl = String.format("http://%s:4444/wd/hub", gridHost);
        
        WebDriver driver = new RemoteWebDriver(new URL(gridUrl), options);
        
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(10));
        
        driver.get("https://www.google.com");
        System.out.println("Title: " + driver.getTitle());

        driver.quit();
    }
}