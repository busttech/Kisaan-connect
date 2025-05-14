import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isPosting = false;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    const cloudName = 'dcrnknrfq';
    const uploadPreset = 'Tarun1940c';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(responseData);
      return data['secure_url'];
    } else {
      print('Image upload failed: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<void> _addPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _contentController.text.isEmpty) return;

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToCloudinary(_selectedImage!);
    }

    await FirebaseFirestore.instance.collection('community_posts').add({
      'userId': user.uid,
      'username': user.displayName ?? 'Anonymous',
      'userPhoto': user.photoURL ?? '',
      'content': _contentController.text,
      'imageUrl': imageUrl ?? '',
      'location': 'Rajgarh/MP',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy': [],
    });

    _contentController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _toggleLike(String postId, List likedBy) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postRef = FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId);
    final isLiked = likedBy.contains(userId);

    await postRef.update({
      'likes': FieldValue.increment(isLiked ? -1 : 1),
      'likedBy':
          isLiked
              ? FieldValue.arrayRemove([userId])
              : FieldValue.arrayUnion([userId]),
    });
  }

  void _showCommentsSheet(BuildContext context, String postId) {
    final TextEditingController _commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Comments",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('community_posts')
                            .doc(postId)
                            .collection('comments')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!.docs;
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            "No comments yet. Be the first to comment!",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (ctx, i) {
                          final comment =
                              comments[i].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  comment['userPhoto'] != null &&
                                          comment['userPhoto'] != ''
                                      ? NetworkImage(comment['userPhoto'])
                                      : null,
                              child:
                                  (comment['userPhoto'] == null ||
                                          comment['userPhoto'] == '')
                                      ? Icon(Icons.person)
                                      : null,
                            ),
                            title: Text(
                              comment['username'] ?? 'User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              comment['text'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            trailing: Text(
                              comment['timestamp'] != null &&
                                      comment['timestamp'] is Timestamp
                                  ? TimeOfDay.fromDateTime(
                                    (comment['timestamp'] as Timestamp)
                                        .toDate(),
                                  ).format(context)
                                  : '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          FirebaseAuth.instance.currentUser?.photoURL != null
                              ? NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!,
                              )
                              : null,
                      child:
                          FirebaseAuth.instance.currentUser?.photoURL == null
                              ? Icon(Icons.person)
                              : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            border: InputBorder.none,
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.green),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (_commentController.text.trim().isEmpty ||
                            user == null)
                          return;
                        await FirebaseFirestore.instance
                            .collection('community_posts')
                            .doc(postId)
                            .collection('comments')
                            .add({
                              'userId': user.uid,
                              'username': user.displayName ?? 'Anonymous',
                              'userPhoto': user.photoURL ?? '',
                              'text': _commentController.text.trim(),
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                        _commentController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          _isSearchVisible ? 120 : 60,
        ), // Adjust height dynamically
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Community",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                if (_isSearchVisible) // Show search bar if visible
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search schemes...",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible; // Toggle visibility
                });
              },
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            FirebaseAuth.instance.currentUser?.photoURL != null
                                ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!,
                                )
                                : null,
                        child:
                            FirebaseAuth.instance.currentUser?.photoURL == null
                                ? Icon(Icons.person, size: 28)
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          child: TextField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              hintText: 'Share your farming experience...',
                              border: InputBorder.none,
                            ),
                            minLines: 1,
                            maxLines: 4,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            (_contentController.text.trim().isEmpty &&
                                        _selectedImage == null) ||
                                    _isPosting
                                ? null
                                : () async {
                                  setState(() => _isPosting = true);
                                  await _addPost();
                                  setState(() => _isPosting = false);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isPosting
                                ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  "Post",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red[300]),
                        onPressed: () => setState(() => _selectedImage = null),
                        tooltip: "Remove image",
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: _isPosting ? null : _pickImage,
                        icon: Icon(Icons.image, color: Colors.grey[700]),
                        label: Text(
                          'Photo',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: null,
                        icon: Icon(
                          Icons.video_collection_outlined,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          'Video',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: null,
                        icon: Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          'Location',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('community_posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return Center(
                    child: Text(
                      "No posts yet. Be the first to share your experience!",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (ctx, i) {
                    final data = posts[i];
                    final postData = data.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage:
                                    data['userPhoto'] != ''
                                        ? NetworkImage(data['userPhoto'])
                                        : null,
                                child:
                                    data['userPhoto'] == ''
                                        ? Icon(Icons.person)
                                        : null,
                              ),
                              title: Text(
                                data['username'],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Rajgarh,MP • recent',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Icon(
                                Icons.more_vert,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (postData.containsKey('imageUrl') &&
                                postData['imageUrl'] != '')
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    postData['imageUrl'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                progress.expectedTotalBytes !=
                                                        null
                                                    ? progress
                                                            .cumulativeBytesLoaded /
                                                        progress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                data['content'] ?? '',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color:
                                        data['likedBy'].contains(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid,
                                            )
                                            ? Colors.red
                                            : Colors.grey,
                                  ),
                                  onPressed:
                                      () =>
                                          _toggleLike(data.id, data['likedBy']),
                                ),
                                Text('${data['likes']} likes'),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed:
                                      () =>
                                          _showCommentsSheet(context, data.id),
                                  icon: Icon(
                                    Icons.comment_outlined,
                                    color: Colors.grey[700],
                                  ),
                                  label: Text(
                                    "Comments",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
