class CatalogEntry {
  const CatalogEntry({
    required this.productId,
    required this.name,
    required this.aliases,
    required this.price,
  });

  final String productId;
  final String name;
  final List<String> aliases;
  final int price;
}

sealed class ParsedCommand {
  const ParsedCommand();
}

class AddItem extends ParsedCommand {
  const AddItem({
    required this.productId,
    required this.qty,
    this.lineTotalOverride,
    required this.confidence,
    required this.sourceText,
  });

  final String productId;
  final int qty;
  final int? lineTotalOverride;
  final double confidence;
  final String sourceText;
}

class RemoveItem extends ParsedCommand {
  const RemoveItem({required this.productId, required this.sourceText});

  final String productId;
  final String sourceText;
}

class RemoveLast extends ParsedCommand {
  const RemoveLast();
}

class ClearCart extends ParsedCommand {
  const ClearCart();
}

class SetPayment extends ParsedCommand {
  const SetPayment({this.amount});

  final int? amount; // null = uang pas
}

class Unknown extends ParsedCommand {
  const Unknown({required this.sourceText});

  final String sourceText;
}

enum IssueType {
  unknownProduct,
  lowConfidence,
  priceMismatch,
  ambiguous,
}

class ParseIssue {
  const ParseIssue({
    required this.type,
    required this.sourceText,
    this.suggestions = const [],
  });

  final IssueType type;
  final String sourceText;
  final List<String> suggestions;
}

class ParseResult {
  const ParseResult({
    this.commands = const [],
    this.issues = const [],
  });

  final List<ParsedCommand> commands;
  final List<ParseIssue> issues;
}

class ParserConfig {
  const ParserConfig({
    this.autoMatchThreshold = 0.88,
    this.suggestThreshold = 0.75,
  });

  final double autoMatchThreshold;
  final double suggestThreshold;
}
