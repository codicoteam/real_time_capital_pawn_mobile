// auctions_mngmt_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import '../../../config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/shared_pref_methods.dart';

class AuctionsServices {
  /// GET AUCTIONS LIST with pagination and filters
  static Future<APIResponse<AuctionsResponse>> getAuctions({
    int page = 1,
    int limit = 10,
    String? status,
    String? auctionType,
    String? category,
    String? assetId,
    String? createdFrom,
    String? createdTo,
    String? startsFrom,
    String? startsTo,
    String? endsFrom,
    String? endsTo,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    final token = await CacheUtils.checkToken();
    var headers = {
      'accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // Build query parameters
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy!,
      'sort_order': sortOrder!,
    };

    if (status != null && status.isNotEmpty && status != 'All') {
      params['status'] = status.toLowerCase();
    }
    if (auctionType != null && auctionType.isNotEmpty && auctionType != 'All') {
      params['auction_type'] = auctionType.toLowerCase();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      params['category'] = category.toLowerCase().replaceAll(' ', '_');
    }
    if (assetId != null && assetId.isNotEmpty) params['asset_id'] = assetId;
    if (createdFrom != null && createdFrom.isNotEmpty)
      params['created_from'] = createdFrom;
    if (createdTo != null && createdTo.isNotEmpty)
      params['created_to'] = createdTo;
    if (startsFrom != null && startsFrom.isNotEmpty)
      params['starts_from'] = startsFrom;
    if (startsTo != null && startsTo.isNotEmpty) params['starts_to'] = startsTo;
    if (endsFrom != null && endsFrom.isNotEmpty) params['ends_from'] = endsFrom;
    if (endsTo != null && endsTo.isNotEmpty) params['ends_to'] = endsTo;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/auctions',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching auctions: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Auctions response status: ${response.statusCode}');
      DevLogs.logInfo('Auctions response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final auctions = List<Map<String, dynamic>>.from(
            data['auctions'] ?? [],
          ).map((auctionJson) => Auction.fromJson(auctionJson)).toList();

          final pagination = Pagination.fromJson(data['pagination'] ?? {});

          final responseObj = AuctionsResponse(
            auctions: auctions,
            pagination: pagination,
          );

          DevLogs.logSuccess(
            'Fetched ${auctions.length} auctions successfully',
          );

          return APIResponse<AuctionsResponse>(
            success: true,
            data: responseObj,
            message:
                responseData['message'] ?? 'Auctions retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch auctions';
          DevLogs.logError('Auctions fetch failed: $errorMessage');

          return APIResponse<AuctionsResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Auctions HTTP error: $errorMessage');

        return APIResponse<AuctionsResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching auctions: $e');
      return APIResponse<AuctionsResponse>(
        success: false,
        message: 'An error occurred while fetching auctions: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET AUCTION DETAILS by ID
  static Future<APIResponse<AuctionDetailResponse>> getAuctionDetails({
    required String auctionId,
  }) async {
    final token = await CacheUtils.checkToken();
    var headers = {
      'accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiKeys.baseUrl}/auctions/$auctionId');

    DevLogs.logInfo('Fetching auction details: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo(
        'Auction details response status: ${response.statusCode}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final auction = Auction.fromJson(data['auction']);
          final currentBid = data['current_bid'] != null
              ? Bid.fromJson(data['current_bid'])
              : null;

          final responseObj = AuctionDetailResponse(
            auction: auction,
            currentBid: currentBid,
          );

          DevLogs.logSuccess('Fetched auction details successfully');

          return APIResponse<AuctionDetailResponse>(
            success: true,
            data: responseObj,
            message:
                responseData['message'] ??
                'Auction details retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch auction details';
          DevLogs.logError('Auction details fetch failed: $errorMessage');

          return APIResponse<AuctionDetailResponse>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Auction details HTTP error: $errorMessage');

        return APIResponse<AuctionDetailResponse>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching auction details: $e');
      return APIResponse<AuctionDetailResponse>(
        success: false,
        message:
            'An error occurred while fetching auction details: ${e.toString()}',
        data: null,
      );
    }
  }

  /// GET LIVE AUCTIONS
  static Future<APIResponse<List<Auction>>> getLiveAuctions({
    String? category,
  }) async {
    final token = await CacheUtils.checkToken();
    var headers = {
      'accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final params = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'All') {
      params['category'] = category.toLowerCase().replaceAll(' ', '_');
    }

    final uri = Uri.parse(
      '${ApiKeys.baseUrl}/auctions/live',
    ).replace(queryParameters: params);

    DevLogs.logInfo('Fetching live auctions: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = response.body;
      final responseData = json.decode(responseBody);

      DevLogs.logInfo('Live auctions response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true) {
          final auctions = List<Map<String, dynamic>>.from(
            responseData['data'] ?? [],
          ).map((auctionJson) => Auction.fromJson(auctionJson)).toList();

          DevLogs.logSuccess(
            'Fetched ${auctions.length} live auctions successfully',
          );

          return APIResponse<List<Auction>>(
            success: true,
            data: auctions,
            message:
                responseData['message'] ??
                'Live auctions retrieved successfully',
          );
        } else {
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch live auctions';
          DevLogs.logError('Live auctions fetch failed: $errorMessage');

          return APIResponse<List<Auction>>(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage =
            responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
        DevLogs.logError('Live auctions HTTP error: $errorMessage');

        return APIResponse<List<Auction>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      DevLogs.logError('Error fetching live auctions: $e');
      return APIResponse<List<Auction>>(
        success: false,
        message:
            'An error occurred while fetching live auctions: ${e.toString()}',
        data: null,
      );
    }
  }
}

// Add to auctions_mngmt_service.dart

/// SEARCH AUCTIONS
static Future<APIResponse<List<Auction>>> searchAuctions({
  required String query,
  String? status,
}) async {
  final token = await CacheUtils.checkToken();
  var headers = {
    'accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // Validate query length (minimum 2 characters)
  if (query.length < 2) {
    return APIResponse<List<Auction>>(
      success: false,
      message: 'Search term must be at least 2 characters',
      data: null,
    );
  }

  final params = <String, String>{
    'q': query,
  };

  if (status != null && status.isNotEmpty && status != 'All') {
    params['status'] = status.toLowerCase();
  }

  final uri = Uri.parse(
    '${ApiKeys.baseUrl}/auctions/search',
  ).replace(queryParameters: params);

  DevLogs.logInfo('Searching auctions: $uri');

  try {
    final response = await http.get(uri, headers: headers);
    final responseBody = response.body;
    final responseData = json.decode(responseBody);

    DevLogs.logInfo('Search response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['success'] == true) {
        final data = responseData['data'];
        final auctions = List<Map<String, dynamic>>.from(data ?? [])
            .map((auctionJson) => Auction.fromJson(auctionJson))
            .toList();

        DevLogs.logSuccess(
          'Found ${auctions.length} auctions in search',
        );

        return APIResponse<List<Auction>>(
          success: true,
          data: auctions,
          message: responseData['message'] ?? 'Search completed successfully',
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to search auctions';
        DevLogs.logError('Search failed: $errorMessage');

        return APIResponse<List<Auction>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } else {
      final errorMessage =
          responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
      DevLogs.logError('Search HTTP error: $errorMessage');

      return APIResponse<List<Auction>>(
        success: false,
        message: errorMessage,
        data: null,
      );
    }
  } catch (e) {
    DevLogs.logError('Error searching auctions: $e');
    return APIResponse<List<Auction>>(
      success: false,
      message: 'An error occurred while searching auctions: ${e.toString()}',
      data: null,
    );
  }
}

/// GET BIDS FOR AN AUCTION
static Future<APIResponse<List<Bid>>> getAuctionBids({
  required String auctionId,
}) async {
  final token = await CacheUtils.checkToken();
  var headers = {
    'accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final uri = Uri.parse('${ApiKeys.baseUrl}/auctions/$auctionId/bids');

  DevLogs.logInfo('Fetching auction bids: $uri');

  try {
    final response = await http.get(uri, headers: headers);
    final responseBody = response.body;
    final responseData = json.decode(responseBody);

    DevLogs.logInfo('Auction bids response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['success'] == true) {
        final bids = List<Map<String, dynamic>>.from(responseData['data'] ?? [])
            .map((bidJson) => Bid.fromJson(bidJson))
            .toList();

        DevLogs.logSuccess('Fetched ${bids.length} bids successfully');

        return APIResponse<List<Bid>>(
          success: true,
          data: bids,
          message:
              responseData['message'] ?? 'Auction bids retrieved successfully',
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'Failed to fetch auction bids';
        DevLogs.logError('Auction bids fetch failed: $errorMessage');

        return APIResponse<List<Bid>>(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } else {
      final errorMessage =
          responseData['message'] ?? 'HTTP Error: ${response.statusCode}';
      DevLogs.logError('Auction bids HTTP error: $errorMessage');

      return APIResponse<List<Bid>>(
        success: false,
        message: errorMessage,
        data: null,
      );
    }
  } catch (e) {
    DevLogs.logError('Error fetching auction bids: $e');
    return APIResponse<List<Bid>>(
      success: false,
      message:
          'An error occurred while fetching auction bids: ${e.toString()}',
      data: null,
    );
  }
}

class AuctionsResponse {
  final List<Auction> auctions;
  final Pagination pagination;

  AuctionsResponse({required this.auctions, required this.pagination});
}

class AuctionDetailResponse {
  final Auction auction;
  final Bid? currentBid;

  AuctionDetailResponse({required this.auction, this.currentBid});
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }
}
