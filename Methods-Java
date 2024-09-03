import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;
import java.util.Scanner;

public class JiraAPIHandler {

    private static final String BASE_URL = "your_base_url_here"; // Replace with your Jira base URL
    private static final String BEARER_TOKEN = "your_bearer_token_here"; // Replace with your Jira Bearer token
    private static final String INPUT_CSV = "input.csv"; // Path to your input CSV file
    private static final String OUTPUT_CSV = "output.csv"; // Path to your output CSV file

    public static void main(String[] args) {
        try {
            // Read the input CSV file
            Reader reader = new FileReader(INPUT_CSV);
            Iterable<CSVRecord> records = CSVFormat.DEFAULT.withHeader("key1", "key2").withSkipHeaderRecord().parse(reader);

            // Create the output CSV file with headers
            FileWriter writer = new FileWriter(OUTPUT_CSV);
            CSVPrinter csvPrinter = new CSVPrinter(writer, CSVFormat.DEFAULT.withHeader("key1", "key2", "testExcId", "Total", "Pass", "Fail", "Executing", "NotRun"));

            // Process each record from the input CSV
            for (CSVRecord record : records) {
                String key1 = record.get("key1");
                String key2 = record.get("key2");

                // Make the first API call to get testExcId
                String testExcId = getTestExcId(key1, key2);
                if (testExcId != null) {
                    // Make the second API call using testExcId to get test case stats
                    TestCaseStats stats = getTestCaseStats(testExcId);

                    // Write the data to the output CSV
                    csvPrinter.printRecord(key1, key2, testExcId, stats.total, stats.pass, stats.fail, stats.executing, stats.notRun);
                } else {
                    System.out.println("Error: Failed to get testExcId for key1=" + key1 + ", key2=" + key2);
                }
            }

            // Close the printer and reader
            csvPrinter.close();
            reader.close();
            System.out.println("Output CSV generated successfully.");

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Method to get testExcId from the first API call
    private static String getTestExcId(String key1, String key2) {
        try {
            String urlString = BASE_URL + "/rest/raven/1.0/api/testrun?testExecIssueKey=" + key1 + "&testIssueKey=" + key2;
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + BEARER_TOKEN);
            conn.connect();

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                Scanner scanner = new Scanner(url.openStream());
                StringBuilder response = new StringBuilder();
                while (scanner.hasNext()) {
                    response.append(scanner.nextLine());
                }
                scanner.close();
                // Parse the response to extract testExcId
                return parseTestExcId(response.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Method to parse testExcId from the first API response
    private static String parseTestExcId(String response) {
        // Parse the response string to extract testExcId using Gson
        JsonObject jsonObject = JsonParser.parseString(response).getAsJsonObject();
        return jsonObject.get("testExcId").getAsString();
    }

    // Method to get test case stats from the second API call using testExcId
    private static TestCaseStats getTestCaseStats(String testExcId) {
        try {
            String urlString = BASE_URL + "/rest/raven/1.0/api/testrun/" + testExcId + "/step";
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + BEARER_TOKEN);
            conn.connect();

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                Scanner scanner = new Scanner(url.openStream());
                StringBuilder response = new StringBuilder();
                while (scanner.hasNext()) {
                    response.append(scanner.nextLine());
                }
                scanner.close();
                // Parse the response to extract test case stats
                return parseTestCaseStats(response.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new TestCaseStats(0, 0, 0, 0, 0);
    }

    // Method to parse test case stats from the second API response
    private static TestCaseStats parseTestCaseStats(String response) {
        JsonArray itemsArray = JsonParser.parseString(response).getAsJsonArray();
        int total = itemsArray.size();
        int pass = (int) itemsArray.stream().filter(item -> item.getAsJsonObject().get("status").getAsString().equals("PASS")).count();
        int fail = (int) itemsArray.stream().filter(item -> item.getAsJsonObject().get("status").getAsString().equals("FAIL")).count();
        int executing = (int) itemsArray.stream().filter(item -> item.getAsJsonObject().get("status").getAsString().equals("EXECUTING")).count();
        int notRun = (int) itemsArray.stream().filter(item -> item.getAsJsonObject().get("status").getAsString().equals("NOT_RUN")).count();
        return new TestCaseStats(total, pass, fail, executing, notRun);
    }

    // Inner class to hold test case stats
    static class TestCaseStats {
        int total, pass, fail, executing, notRun;

        TestCaseStats(int total, int pass, int fail, int executing, int notRun) {
            this.total = total;
            this.pass = pass;
            this.fail = fail;
            this.executing = executing;
            this.notRun = notRun;
        }
    }
}
