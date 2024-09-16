package pckdefault;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

public class CreateDic_File {
	
	public static void main(String args[]) {
		String userHome = System.getProperty("user.dir");
		System.out.println(userHome);
		String dirName = userHome + File.separator + "Execution Reports";
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MMM-yyyy");
		
		String fileName = dirName + File.separator + "Jira_Execution_"+LocalDate.now().format(DateTimeFormatter.ofPattern("dd-MMM-yyyy"))+".csv";
		System.out.println(dirName+"\n"+fileName);
		
		File dir = new File(dirName);
		
		//Create a Dir file
		if(!dir.exists()) {
			if(dir.mkdirs()) {
				System.out.println("Directory created: " + dirName);
            } else {
                System.out.println("Failed to create directory!");
                return;
            }
		}
		
		List<String[]> data = Arrays.asList(
                new String[]{"ID", "Name", "Age"},
                new String[]{"1", "John", "25"},
                new String[]{"2", "Jane", "30"},
                new String[]{"3", "Bob", "22"}
        );
		
		File csvfile = new File(fileName);
		try(BufferedWriter writer = new BufferedWriter(new FileWriter(csvfile))){
			 System.out.println("CSV file created: " + fileName);
			 for(String[] row : data) {
				 String line = String.join(",", row);
				 writer.write(line);
				 writer.newLine();
			 }
			 System.out.println("Data written to CSV file successfully.");
		}
		catch (IOException e) {
            System.out.println("An error occurred while creating/writing the CSV file.");
            e.printStackTrace();
        }
		
	}

}
