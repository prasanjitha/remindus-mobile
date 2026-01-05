import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:remindus/screens/authentication/siginin_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _vegNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _depEmailController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  String? activeFamilyId;
  String currentUserRole = 'limited';
  List joinedFamilies = [];
  String _selectedAccess = 'limited';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // --- User Info & Specific Role Management ---
  _loadUserInfo() async {
    if (user == null) return;
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      String activeId = data['activeFamilyId'] ?? user!.uid;
      
      setState(() {
        activeFamilyId = activeId;
        joinedFamilies = List.from(data['joinedFamilies'] ?? [user!.uid]);
        
        if (activeFamilyId == user!.uid) {
          currentUserRole = 'owner';
        } else {
          // Look up permission specific to the ACTIVE family group
          Map<String, dynamic> permissions = data['permissions'] ?? {};
          currentUserRole = permissions[activeFamilyId] ?? 'limited';
        }
      });
    }
  }

  // --- Vegetable Management ---
  Future<void> _addVegetable() async {
    if (_vegNameController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('vegetables').add({
      'name': _vegNameController.text,
      'quantity': _qtyController.text,
      'familyId': activeFamilyId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _vegNameController.clear();
    _qtyController.clear();
  }

  // --- Member Management (Permissions Map Update) ---
  Future<void> _addMember() async {
    String email = _depEmailController.text.trim();
    if (email.isEmpty) return;

    var query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

    if (query.docs.isNotEmpty) {
      String depUid = query.docs.first.id;
      
      // Update the member's specific permission for THIS owner only
      await FirebaseFirestore.instance.collection('users').doc(depUid).update({
        'joinedFamilies': FieldValue.arrayUnion([activeFamilyId]),
        'activeFamilyId': activeFamilyId,
        // Dot notation use karala permissions map eke key ekak update karanawa
        'permissions.$activeFamilyId': _selectedAccess, 
      });
      
      _depEmailController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member added with specific access!")));
    } else {
      _showInviteDialog(email);
    }
  }

  Future<void> _removeMember(String memberUid) async {
    await FirebaseFirestore.instance.collection('users').doc(memberUid).update({
      'joinedFamilies': FieldValue.arrayRemove([activeFamilyId]),
      'activeFamilyId': memberUid,
      'permissions.$activeFamilyId': FieldValue.delete(), // Permission eka ain karanawa
    });
  }

  // --- EmailJS Invite ---
  Future<void> sendInviteEmail(String receiverEmail) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': dotenv.env['EMAILJS_SERVICE_ID'],
          'template_id': dotenv.env['EMAILJS_TEMPLATE_ID'],
          'user_id': dotenv.env['EMAILJS_USER_ID'],
          'accessToken': dotenv.env['EMAILJS_ACCESS_TOKEN'],
          'template_params': {'to_email': receiverEmail, 'family_id': activeFamilyId}
        }),
      );
    } catch (e) { log("Email Error: $e"); }
  }

  void _showInviteDialog(String email) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("User Not Found"),
      content: Text("$email is not on RemindUs. Send invitation?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
        ElevatedButton(onPressed: () { Navigator.pop(context); sendInviteEmail(email); }, child: const Text("Invite")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool canEdit = (currentUserRole == 'owner' || currentUserRole == 'full');
    bool isOwner = (currentUserRole == 'owner');

    return Scaffold(
      appBar: AppBar(
        title: Text("RemindUs (${currentUserRole.toUpperCase()})"),
        backgroundColor: Colors.green,
        actions: [
          _buildFamilySwitcher(),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginScreen()));
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (canEdit) _buildAddVegPanel(),
            
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Vegetable Inventory", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildVegetableList(canEdit),

            if (isOwner) ...[
              const Divider(thickness: 2),
              _buildAddMemberPanel(),
              _buildMemberManagementList(),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySwitcher() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').where('uid', whereIn: joinedFamilies).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return DropdownButton<String>(
          value: activeFamilyId,
          underline: const SizedBox(),
          icon: const Icon(Icons.swap_horizontal_circle, color: Colors.white),
          onChanged: (String? newId) async {
            if (newId != null) {
              await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'activeFamilyId': newId});
              _loadUserInfo();
            }
          },
          items: snapshot.data!.docs.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['uid'],
              child: Text(doc['uid'] == user!.uid ? "🏠 My Home" : "👥 ${doc['familyName'] ?? 'Shared List'}"),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAddVegPanel() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _vegNameController, decoration: const InputDecoration(labelText: "Vegetable Name")),
            TextField(controller: _qtyController, decoration: const InputDecoration(labelText: "Quantity")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addVegetable, child: const Text("Add Vegetable")),
          ],
        ),
      ),
    );
  }

  Widget _buildVegetableList(bool canDelete) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vegetables').where('familyId', isEqualTo: activeFamilyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snapshot.data!.docs[i];
            return ListTile(
              title: Text(doc['name']),
              subtitle: Text("Qty: ${doc['quantity']}"),
              trailing: canDelete ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()) : null,
            );
          },
        );
      },
    );
  }

  Widget _buildAddMemberPanel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Text("Add Family Member", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _depEmailController, decoration: const InputDecoration(labelText: "Member Email")),
          DropdownButton<String>(
            value: _selectedAccess,
            onChanged: (v) => setState(() => _selectedAccess = v!),
            items: ['full', 'limited'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
          ),
          ElevatedButton(onPressed: _addMember, child: const Text("Add to Group")),
        ],
      ),
    );
  }

  Widget _buildMemberManagementList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('joinedFamilies', arrayContains: activeFamilyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var members = snapshot.data!.docs.where((d) => d.id != user!.uid).toList();
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, i) {
            var mData = members[i].data() as Map<String, dynamic>;
            Map permissions = mData['permissions'] ?? {};
            String mRole = permissions[activeFamilyId] ?? 'limited';

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(mData['name']),
              subtitle: Text("Role: ${mRole.toUpperCase()}"),
              trailing: IconButton(icon: const Icon(Icons.person_remove, color: Colors.red), onPressed: () => _removeMember(members[i].id)),
            );
          },
        );
      },
    );
  }
}