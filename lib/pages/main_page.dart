import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_page_data_controller.dart';
import '../model/main_page_data.dart';
import '../model/movie.dart';
import '../model/search_category.dart';
import '../widget/movie_tile.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController, MainPageData>((ref) {
  return MainPageDataController();
});

/* final selectedMoviePosterURLProvider = StateProvider<String>((ref) {
  final movies = ref.watch(mainPageDataControllerProvider).movies;
  // set default value of the poster image when we first initialize the StateProvider
  return movies!.isNotEmpty ? movies[0].posterURL() : '';
}); */
// the above OR
final selectedMoviePosterURLProvider = StateProvider<String?>((ref) {
  final movies = ref.watch(mainPageDataControllerProvider).movies!;
  // set default value of the poster image when we first initialize the StateProvider
  return movies.isNotEmpty ? movies[0].posterURL() : null;
});

class MainPage extends ConsumerWidget {
  MainPage({super.key});

  late double _deviceHeight, _deviceWidth;
  late String? _selectedMoviePosterURL;

  late MainPageDataController _mainPageDataController;
  late MainPageData _mainPageData;

  late TextEditingController _searchTextFieldController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _mainPageDataController =
        ref.watch(mainPageDataControllerProvider.notifier);
    _mainPageData = ref.watch(mainPageDataControllerProvider);
    _selectedMoviePosterURL =
        ref.watch(selectedMoviePosterURLProvider.state).state;

    _searchTextFieldController = TextEditingController();
    _searchTextFieldController.text = _mainPageData.searchText!;
    final List<Movie> movies = _mainPageData.movies!;
    //return _buildUI();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /*  _backgroundWidget(),
            _foregroundWidgets(), */
            _selectedMoviePosterURL != null
                ? Container(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(_selectedMoviePosterURL!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    color: Colors.black,
                  ),
            Container(
              padding: EdgeInsets.fromLTRB(0, _deviceHeight * 0.02, 0, 0),
              width: _deviceWidth * 0.88,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _topBarWidget(),
                  Container(
                    height: _deviceHeight * 0.83,
                    padding: EdgeInsets.symmetric(
                      vertical: _deviceHeight * 0.01,
                    ),
                    child: _mainPageData.movies!.isNotEmpty
                        ? NotificationListener(
                            onNotification: ((notification) {
                              if (notification is ScrollEndNotification) {
                                final before =
                                    notification.metrics.extentBefore;
                                final max =
                                    notification.metrics.maxScrollExtent;
                                if (before == max) {
                                  _mainPageDataController.getMovies();
                                  return true;
                                }
                                return false;
                              }
                              return false;
                            }),
                            child: ListView.builder(
                              itemCount: movies.length,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _deviceHeight * 0.01,
                                      horizontal: 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      /* ref
                                    .read(
                                        selectedMoviePosterURLProvider.state)
                                    .state = movies[index].posterURL(); */
                                      // the above line is correct also the down is correct
                                      ref
                                          .read(selectedMoviePosterURLProvider
                                              .notifier)
                                          .state = movies[index].posterURL();
                                    },
                                    child: MovieTile(
                                      movie: movies[index],
                                      height: _deviceHeight * 0.20,
                                      width: _deviceWidth * 0.85,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.white),
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _backgroundWidget(),
            _foregroundWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget() {
    if (_selectedMoviePosterURL != null) {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(_selectedMoviePosterURL!),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        color: Colors.black,
      );
    }
  }

  Widget _foregroundWidgets() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, _deviceHeight * 0.02, 0, 0),
      width: _deviceWidth * 0.88,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _topBarWidget(),
          Container(
            height: _deviceHeight * 0.83,
            padding: EdgeInsets.symmetric(
              vertical: _deviceHeight * 0.01,
            ),
            child: _moviesListViewWidget(),
          )
        ],
      ),
    );
  }

  Widget _topBarWidget() {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_searchFieldWidget(), _categorySelectionWidget()],
      ),
    );
  }

  Widget _searchFieldWidget() {
    const _border = InputBorder.none;
    return SizedBox(
      width: _deviceWidth * 0.50,
      height: _deviceHeight * 0.05,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (value) => _mainPageDataController.updateTextSearch(value),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          focusedBorder: _border,
          border: _border,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white24,
          ),
          hintStyle: TextStyle(color: Colors.white54),
          filled: false,
          fillColor: Colors.white24,
          hintText: 'Search....',
        ),
      ),
    );
  }

  Widget _categorySelectionWidget() {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: _mainPageData.searchCategory,
      icon: const Icon(Icons.menu, color: Colors.white24),
      underline: Container(
        height: 1,
        color: Colors.white24,
      ),
      items: const [
        DropdownMenuItem(
          value: SearchCategory.popular,
          child: Text(
            SearchCategory.popular,
            style: TextStyle(color: Colors.white),
          ),
        ),
        DropdownMenuItem(
          value: SearchCategory.upcoming,
          child: Text(
            SearchCategory.upcoming,
            style: TextStyle(color: Colors.white),
          ),
        ),
        DropdownMenuItem(
          value: SearchCategory.none,
          child: Text(
            SearchCategory.none,
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
      onChanged: (String? value) => value.toString().isNotEmpty
          ? _mainPageDataController.updateSearchCategory(value)
          : null,
    );
  }

  Widget _moviesListViewWidget() {
    final List<Movie> movies = _mainPageData.movies!;

    if (movies.isNotEmpty) {
      return NotificationListener(
        onNotification: ((notification) {
          if (notification is ScrollEndNotification) {
            final before = notification.metrics.extentBefore;
            final max = notification.metrics.maxScrollExtent;
            if (before == max) {
              _mainPageDataController.getMovies();
              return true;
            }
            return false;
          }
          return false;
        }),
        child: ListView.builder(
          itemCount: movies.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  vertical: _deviceHeight * 0.01, horizontal: 0),
              child: GestureDetector(
                onTap: () {
                  _selectedMoviePosterURL = movies[index].posterURL();
                },
                child: MovieTile(
                  movie: movies[index],
                  height: _deviceHeight * 0.20,
                  width: _deviceWidth * 0.85,
                ),
              ),
            );
          }),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    }
  }
}
