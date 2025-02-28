import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdvertisementCarousel extends StatefulWidget {
  @override
  _AdvertisementCarouselState createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late Future<List<String>> _advertisementUrls;
  final ApiService _apiService = ApiService();
  late PageController _pageController;
  int _currentPage = 0;
  int _totalAdsCount = 0; // Store the total ads count

  @override
  void initState() {
    super.initState();
    _advertisementUrls = _apiService.fetchAdvertisements();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start auto-scrolling only after the dependencies are initialized
    _startAutoScroll();
  }

  void _startAutoScroll() {
  Timer.periodic(Duration(seconds: 3), (Timer timer) {
    if (_pageController.hasClients) { // Fix applied
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      int totalPages = _totalAdsCount;
      _currentPage = (_currentPage + 1) % totalPages;
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _advertisementUrls,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Update the total ads count after data is fetched
          _totalAdsCount = snapshot.data!.length;

          return Container(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      snapshot.data![index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(child: Text('No advertisements available.'));
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
