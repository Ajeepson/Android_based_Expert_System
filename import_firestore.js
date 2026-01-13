const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Path to your service account key
const serviceAccountPath = 'C:\\Users\\USER\\Downloads\\crop-system-2de53-firebase-adminsdk-fbsvc-2cd70e5cd2.json';

// Initialize Firebase Admin SDK
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Load sample data
const sampleDataPath = path.join(__dirname, 'firestore_sample_data.json');
const sampleData = JSON.parse(fs.readFileSync(sampleDataPath, 'utf8'));

async function importData() {
  try {
    console.log('🌾 Starting Firestore data import...\n');

    // Import crops
    console.log('📌 Importing Crops...');
    for (const [docId, docData] of Object.entries(sampleData.crops || {})) {
      await db.collection('crops').doc(docId).set(docData);
      console.log(`  ✓ ${docData.name}`);
    }

    // Import diseases
    console.log('\n🦠 Importing Diseases...');
    for (const [docId, docData] of Object.entries(sampleData.diseases || {})) {
      await db.collection('diseases').doc(docId).set(docData);
      console.log(`  ✓ ${docData.name}`);
    }

    // Import symptoms
    console.log('\n🔍 Importing Symptoms...');
    for (const [docId, docData] of Object.entries(sampleData.symptoms || {})) {
      await db.collection('symptoms').doc(docId).set(docData);
      console.log(`  ✓ ${docData.name}`);
    }

    console.log('\n✅ Firestore data import completed successfully!');
    console.log(`📊 Summary:`);
    console.log(`   - Crops: ${Object.keys(sampleData.crops || {}).length}`);
    console.log(`   - Diseases: ${Object.keys(sampleData.diseases || {}).length}`);
    console.log(`   - Symptoms: ${Object.keys(sampleData.symptoms || {}).length}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error importing data:', error);
    process.exit(1);
  }
}

// Run import
importData();
