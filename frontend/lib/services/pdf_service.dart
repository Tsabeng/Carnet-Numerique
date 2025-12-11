import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  static Future<void> exportMedicalRecord({
    required BuildContext context,
    required String patientName,
    required String patientId,
    required String birthDate,
    required String bloodType,
    required List<Map<String, dynamic>> consultations,
    required List<Map<String, dynamic>> allergies,
    required List<Map<String, dynamic>> treatments,
  }) async {
    try {
      final pdf = pw.Document();
      
      // En-tête
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête avec logo
                _buildHeader(),
                pw.SizedBox(height: 20),
                
                // Informations patient
                _buildPatientInfo(
                  patientName: patientName,
                  patientId: patientId,
                  birthDate: birthDate,
                  bloodType: bloodType,
                ),
                pw.SizedBox(height: 30),
                
                // Résumé médical
                _buildMedicalSummary(
                  consultations: consultations,
                  allergies: allergies,
                  treatments: treatments,
                ),
              ],
            );
          },
        ),
      );
      
      // Page des consultations
      if (consultations.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Historique des consultations'),
                  pw.SizedBox(height: 20),
                  ...consultations.map((consultation) => 
                    _buildConsultationCard(consultation)
                  ).toList(),
                ],
              );
            },
          ),
        );
      }
      
      // Page des traitements et allergies
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Traitements et allergies'),
                pw.SizedBox(height: 20),
                
                if (treatments.isNotEmpty) ...[
                  _buildSubSectionTitle('Traitements en cours'),
                  pw.SizedBox(height: 10),
                  ...treatments.map((treatment) => 
                    _buildTreatmentItem(treatment)
                  ).toList(),
                  pw.SizedBox(height: 20),
                ],
                
                if (allergies.isNotEmpty) ...[
                  _buildSubSectionTitle('Allergies connues'),
                  pw.SizedBox(height: 10),
                  ...allergies.map((allergy) => 
                    _buildAllergyItem(allergy)
                  ).toList(),
                ],
                
                // Pied de page
                pw.Spacer(),
                _buildFooter(),
              ],
            );
          },
        ),
      );
      
      // Sauvegarder le PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CARNET MÉDICAL NUMÉRIQUE',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Hôpital Général - Service Informatique Médicale',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.Text(
          'Document confidentiel',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.red,
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildPatientInfo({
    required String patientName,
    required String patientId,
    required String birthDate,
    required String bloodType,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMATIONS PATIENT',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _buildInfoItem('Nom:', patientName),
              pw.SizedBox(width: 30),
              _buildInfoItem('Code patient:', patientId),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              _buildInfoItem('Date de naissance:', birthDate),
              pw.SizedBox(width: 30),
              _buildInfoItem('Groupe sanguin:', bloodType),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  static pw.Widget _buildMedicalSummary({
    required List<Map<String, dynamic>> consultations,
    required List<Map<String, dynamic>> allergies,
    required List<Map<String, dynamic>> treatments,
  }) {
    return pw.Row(
      children: [
        // Consultations
        pw.Expanded(
          child: _buildSummaryCard(
            'Consultations',
            consultations.length.toString(),
            PdfColors.blue,
          ),
        ),
        pw.SizedBox(width: 10),
        
        // Allergies
        pw.Expanded(
          child: _buildSummaryCard(
            'Allergies',
            allergies.length.toString(),
            PdfColors.red,
          ),
        ),
        pw.SizedBox(width: 10),
        
        // Traitements
        pw.Expanded(
          child: _buildSummaryCard(
            'Traitements',
            treatments.length.toString(),
            PdfColors.green,
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE3F2FD),
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue,
      ),
    );
  }
  
  static pw.Widget _buildSubSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }
  
  static pw.Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                consultation['date'] ?? '',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: _getConsultationTypeColor(consultation['type'] ?? ''),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  consultation['type'] ?? 'Consultation',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Médecin: ${consultation['doctor'] ?? ''}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Service: ${consultation['service'] ?? ''}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Diagnostic:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            consultation['diagnosis'] ?? '',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (consultation['prescription'] != null && consultation['prescription'].isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 5),
                pw.Text(
                  'Prescription:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  consultation['prescription'] ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTreatmentItem(Map<String, dynamic> treatment) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 4,
            margin: const pw.EdgeInsets.only(top: 6, right: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.green,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  treatment['name'] ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '${treatment['dosage'] ?? ''} - ${treatment['frequency'] ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildAllergyItem(Map<String, dynamic> allergy) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 4,
            margin: const pw.EdgeInsets.only(top: 6, right: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.red,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  allergy['name'] ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Sévérité: ${allergy['severity'] ?? ''} - Depuis ${allergy['since'] ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Document généré le ${DateTime.now().toLocal()}',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Page',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Confidentialité: Ce document contient des informations médicales confidentielles. '
          'Toute diffusion non autorisée est interdite par la loi.',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.red,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
  
  static PdfColor _getConsultationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'consultation':
        return PdfColors.blue;
      case 'urgence':
        return PdfColors.red;
      case 'suivi':
        return PdfColors.green;
      default:
        return PdfColors.grey;
    }
  }
  
  static Future<void> exportAppointmentReport({
    required BuildContext context,
    required List<Map<String, dynamic>> appointments,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Méthode similaire pour exporter un rapport de rendez-vous
  }
}