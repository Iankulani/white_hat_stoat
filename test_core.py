"""
Core functionality tests for WHITE-HAT-STOAT
"""

import pytest
from white_hat_stoat import (
    CommandHandler,
    DatabaseManager,
    ConfigManager,
    NetworkTools,
    Version,
    Name
)

class TestCore:
    def test_version(self):
        assert Version == "1.0.0"
    
    def test_name(self):
        assert Name == "WHITE-HAT-STOAT"
    
    def test_config_manager(self, mock_config):
        assert mock_config.get("version") == "1.0.0"
        mock_config.set("test_key", "test_value")
        assert mock_config.get("test_key") == "test_value"
    
    def test_database_manager(self, mock_db):
        # Test command logging
        mock_db.log_command("test command", "local", "test", "test_user", True, "test output")
        stats = mock_db.get_statistics()
        assert stats.get("total_commands", 0) >= 1
        
        # Test threat logging
        mock_db.log_threat("test", "127.0.0.1", "low", "test threat")
        threats = mock_db.get_recent_threats(5)
        assert len(threats) >= 1
    
    def test_network_tools(self):
        # Test ping (should work on most systems)
        result = NetworkTools.ping("127.0.0.1", 1)
        assert result.success is True
        
        # Test local IP
        ip = NetworkTools.get_local_ip()
        assert ip is not None
        
        # Test whois (should be available)
        result = NetworkTools.whois("google.com")
        assert result is not None

class TestCommandHandler:
    def test_command_handler_init(self, mock_db):
        handler = CommandHandler(mock_db)
        assert handler is not None
        
        # Test help command
        result = handler.execute("help")
        assert result["success"] is True
        assert "WHITE-HAT-STOAT" in result["output"]
    
    def test_ping_command(self, mock_db):
        handler = CommandHandler(mock_db)
        result = handler.execute("ping 127.0.0.1")
        assert result["success"] is True
        
    def test_invalid_command(self, mock_db):
        handler = CommandHandler(mock_db)
        result = handler.execute("invalid_command_xyz")
        assert result["success"] is False