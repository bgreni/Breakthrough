import 'game_engine.dart';

enum PieceType { Pawn, Rook, Knight, Bishop, Queen, King }

enum PieceColor {
  White,
  Black,
}

/// Controller for programmatically controlling the board
class BoardController {
  /// The game attached to the controller
  GameEngine game;

  /// Function from the ScopedModel to refresh board
  Function refreshBoard;

  /// Makes move on the board
  // void makeMove(String from, String to) {
  //   game?.move({"from": from, "to": to});
  //   refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  // }
  //
  // /// Resets square
  // void resetBoard() {
  //   game?.reset();
  //   refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  // }
  //
  // /// Clears board
  // void clearBoard() {
  //   game?.clear();
  //   refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  // }

  // /// Puts piece on a square
  // void putPiece(PieceType piece, String square, PieceColor color) {
  //   game?.put(_getPiece(piece, color), square);
  //   refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  // }
  //
  // /// Loads a PGN
  // void loadPGN(String pgn) {
  //   game.load_pgn(pgn);
  //   refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  // }
  //
  // /// Exception when a controller is not attached to a board
  // void _throwNotAttachedException() {
  //   throw Exception("Controller not attached to a ChessBoard widget!");
  // }
  //
  // /// Gets respective piece
  // chess.Piece _getPiece(PieceType piece, PieceColor color) {
  //   chess.Color _getColor(PieceColor color) {
  //     return color == PieceColor.White ? chess.Color.WHITE : chess.Color.BLACK;
  //   }
  //
  //   return chess.Piece(chess.PieceType.PAWN, _getColor(color));
  //   }

}