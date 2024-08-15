import 'dart:io';
import 'package:aitravelplanner/addStory/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddStoryPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final addStoryController controller = Get.put(addStoryController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: controller.descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: controller.authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
              SizedBox(height: 16),
              controller.imageFile.value == null
                  ? Text('No image selected.')
                  : Image.file(File(controller.imageFile.value!.path), height: 150),
              SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.pickImage,
                    child: Text('Pick Image'),
                  ),
                  Obx(() {
                    return DropdownButton<String>(
                      value: controller.type.value,
                      onChanged: (String? newValue) {
                        controller.type.value = newValue!;
                      },
                      items: <String>['Fantasy', 'Horror', 'Sci-Fi']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: Text('Select Type'),
                    );
                  }),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isGenerating.value ? null : controller.generateDescription,
                      child: controller.isGenerating.value
                          ? CircularProgressIndicator()
                          : Text('Generate Story with AI'),
                    );
                  }),
                  ElevatedButton(
                    onPressed: controller.uploadStory,
                    child: Text('Add Story'),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
