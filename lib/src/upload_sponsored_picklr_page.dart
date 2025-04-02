import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitch/src/models/sponsored_club_model.dart';
import 'package:hitch/src/services/court_finder_service.dart';
import 'package:hitch/src/widgets/primary_btn.dart';

class UploadSponsoredPicklrPage extends StatefulWidget{
  const UploadSponsoredPicklrPage({super.key});

  @override
  State<UploadSponsoredPicklrPage> createState() => _UploadSponsoredPicklrPageState();
}

class _UploadSponsoredPicklrPageState extends State<UploadSponsoredPicklrPage> {
  List<SponsoredClubModel> sponsoredData = [];
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: ListView.builder(
                itemCount: sponsoredData.length,
                itemBuilder: (ctx, index){
                  return ListTile(
                    title: Text(sponsoredData[index].name),
                    subtitle: Text(sponsoredData[index].address),
                  );
            })),

            SizedBox(
              width: 200,
              child: PrimaryBtn(btnText: "Upload", onTap: _onUploadTap, isLoading: uploading,)
            )
          ],
        ),
      ),
    );
  }

  // Function to load CSV data
  Future<void> loadCsvData() async {
    final String csvString = await rootBundle.loadString('assets/csv/sponsored_clubs.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

    // Remove header row
    csvTable.removeAt(0);

    sponsoredData =  csvTable.map((row) => SponsoredClubModel.fromCsv(row)).toList();
    setState(() {});
  }

  void _onUploadTap()async{
    setState(() => uploading = true);
    await CourtFinderService.uploadSponsoredPicklrToDb(sponsoredClubs: sponsoredData);
    setState(() => uploading = false);
  }
}