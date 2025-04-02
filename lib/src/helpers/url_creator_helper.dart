class UrlCreatorHelper {
  static String generateTournamentUrl(String title) {
    // Convert to lowercase
    String urlSlug = title.toLowerCase();

    // Remove special characters except spaces and hyphens
    urlSlug = urlSlug.replaceAll(RegExp(r"[^\w\s-]"), "");

    // Replace spaces with hyphens
    urlSlug = urlSlug.replaceAll(RegExp(r"\s+"), "-");

    // Construct the final URL
    return "https://pickleballtournaments.com/tournaments/$urlSlug";
  }
}