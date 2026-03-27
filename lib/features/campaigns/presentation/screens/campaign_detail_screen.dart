import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/campaign_api_service.dart';
import '../../data/models/campaign_model.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  final String accessToken;
  const CampaignDetailScreen({super.key, required this.campaign, required this.accessToken});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final _apiService = CampaignApiService();
  bool _isGenerating = false;

  void _generateScript() async {
    setState(() => _isGenerating = true);
    final result = await _apiService.getAiScript(widget.campaign.id, widget.accessToken);
    setState(() => _isGenerating = false);

    if (result != null && mounted) {
      _showScriptModal(result['script']);
    }
  }

  void _showScriptModal(String markdown) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome, size: 40, color: Colors.purple),
              const SizedBox(height: 10),
              const Text('¡Guión generado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(20)),
                  child: Markdown(
                    controller: scrollController,
                    data: markdown,
                    styleSheet: MarkdownStyleSheet(
                      h3: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      p: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: Colors.black), child: const Text('Copiar'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.campaign;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageHeader(c.image),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text(c.businessName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 25),
                      _buildInfoRow(c),
                      const SizedBox(height: 30),
                      const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(c.description, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF444444))),
                      const SizedBox(height: 30),
                      _buildAiSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                )
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildImageHeader(String url) {
    return Stack(
      children: [
        Image.network(url, height: 300, width: double.infinity, fit: BoxFit.cover),
        Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.white, child: const BackButton(color: Colors.black))),
        Positioned(
          bottom: -1, left: 0, right: 0,
          child: Container(height: 30, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)))),
        ),
      ],
    );
  }

  Widget _buildInfoRow(Campaign c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoItem('Tipo', c.creatorType),
        _infoItem('Plataformas', 'TikTok/IG'),
        _infoItem('Fecha Límite', '30 Abr'),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildAiSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Guiones Inteligentes', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Crea contenido con IA', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
          FilledButton.icon(
            onPressed: _isGenerating ? null : _generateScript,
            icon: _isGenerating ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Crear Guion'),
            style: FilledButton.styleFrom(backgroundColor: Colors.black),
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 30, left: 24, right: 24,
      child: SizedBox(
        height: 56, width: double.infinity,
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
          child: const Text('Unirme a la Campaña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}