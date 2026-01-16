// lib/helpers/medicine_helper.dart

class MedicineHelper {
  static final List<String> suggestions = [
    "Panadol", "Paracetamol", "Aspirin", "Ibuprofen", "Diclofenac Sodium", 
    "Diclofenac Potassium", "Mefenamic Acid", "Ponstan", "Naproxen", "Tramadol", 
    "Morphine", "Codeine", "Celecoxib", "Etoricoxib", "Arcoxia", "Fentanyl",
    "Omeprazole", "Pantoprazole", "Esomeprazole", "Rabeprazole", "Lansoprazole", 
    "Famotidine", "Ranitidine", "Gaviscon", "Digene", "Eno", "Domperidone", 
    "Metoclopramide", "Hyoscine (Buscopan)", "Mebeverine", "Activated Charcoal", 
    "Lactulose", "Bisacodyl", "Cremaffin",
    "Metformin", "Gliclazide", "Glimepiride", "Pioglitazone", "Sitagliptin", 
    "Vildagliptin", "Dapagliflozin", "Insulin Actrapid", "Insulin Mixtard", 
    "Insulin Lantus", "Metformin ER",
    "Atorvastatin", "Rosuvastatin", "Simvastatin", "Losartan Potassium", 
    "Valsartan", "Telmisartan", "Amlodipine", "Nifedipine", "Diltiazem", 
    "Enalapril", "Lisinopril", "Ramipril", "Atenolol", "Bisoprolol", 
    "Metoprolol", "Carvedilol", "Propranolol", "Spironolactone", 
    "Furosemide (Lasix)", "Hydrochlorothiazide", "Clopidogrel", "Warfarin", 
    "Rivaroxaban", "Digoxin", "Glyceryl Trinitrate (GTN)",
    "Amoxicillin", "Amoxicillin & Clavulanic Acid (Augmentin)", "Cloxacillin", 
    "Flucloxacillin", "Cephalexin", "Cefuroxime", "Cefixime", "Ceftriaxone", 
    "Azithromycin", "Clarithromycin", "Erythromycin", "Ciprofloxacin", 
    "Levofloxacin", "Metronidazole (Flagyl)", "Doxycycline", "Tetracycline", 
    "Nitrofurantoin", "Acyclovir", "Oseltamivir",
    "Chlorpheniramine (Piriton)", "Cetirizine", "Loratadine", "Desloratadine", 
    "Fexofenadine (Allegra)", "Levocetirizine", "Prednisolone", "Dexamethasone", 
    "Hydrocortisone", "Salbutamol (Ventolin Inhaler)", "Beclomethasone", 
    "Fluticasone", "Montelukast", "Theophylline", "Aminophylline", 
    "Budesonide", "Tiotropium",
    "Vitamin C (Ascorbic Acid)", "Vitamin D3", "Vitamin B Complex", "Vitamin B12", 
    "Vitamin E", "Folic Acid", "Calcium Carbonate", "Calcium Lactate", 
    "Iron Supplement (Ferrous Sulfate)", "Zinc Gluconate", "Multivitamin", 
    "Omega 3 (Fish Oil)", "Magnesium Sulfate", "Glucosamine",
    "Diazepam", "Lorazepam", "Alprazolam (Xanax)", "Clonazepam", "Amitriptyline", 
    "Fluoxetine", "Sertraline", "Escitalopram", "Risperidone", "Olanzapine", 
    "Quetiapine", "Lithium Carbonate", "Haloperidol", "Zolpidem",
    "Thyroxine (Eltroxin)", "Carbimazole", "Propylthiouracil", "Ethinylestradiol", 
    "Progesterone", "Testosterone", "Clomiphene", "Tamoxifen",
    "Metronidazole", "Mebendazole (Vermox)", "Albendazole", "Permethrin", 
    "Betamethasone", "Clotrimazole", "Mupirocin", "Fusidic Acid", 
    "Eye Drops (Tears Natural)", "Chloramphenicol Eye Drops", "Timolol Maleate", 
    "Latanoprost", "Phenytoin", "Sodium Valproate", "Carbamazepine", 
    "Gabapentin", "Pregabalin", "Levetiracetam", "Warfarin", "Heparin"
  ];

  static List<String> getSortedSuggestions() {
    List<String> sortedList = List.from(suggestions);
    sortedList.sort();
    return sortedList;
  }
}