"""
WHITE-HAT-STOAT Test Configuration
"""

import pytest
import os
import sys
import tempfile
import shutil
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

@pytest.fixture(scope="session")
def test_data_dir():
    """Create temporary test data directory"""
    tmp_dir = tempfile.mkdtemp(prefix="stoat_test_")
    yield tmp_dir
    shutil.rmtree(tmp_dir, ignore_errors=True)

@pytest.fixture
def mock_db(test_data_dir):
    """Create mock database for testing"""
    from white_hat_stoat import DatabaseManager
    db_path = os.path.join(test_data_dir, "test.db")
    db = DatabaseManager(db_path)
    yield db
    db.close()

@pytest.fixture
def mock_config(test_data_dir):
    """Create mock configuration for testing"""
    from white_hat_stoat import ConfigManager
    config = ConfigManager()
    config.config_dir = Path(test_data_dir)
    config.config_file = config.config_dir / "config.json"
    config.config = config.DEFAULT_CONFIG.copy()
    yield config