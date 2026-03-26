import subprocess
import sys
import re
from pathlib import Path


def test_queries_file_exists():
    assert Path("queries.sql").exists(), "queries.sql not found"


def test_kpi_brief_exists():
    path = Path("kpi_brief.md")
    assert path.exists(), "kpi_brief.md not found"
    content = path.read_text()
    assert len(content) > 200, "kpi_brief.md appears too short — fill in all 3 KPIs"


def test_queries_sql_has_9_queries():
    content = Path("queries.sql").read_text()
    markers = re.findall(r'--\s*Q\d+', content)
    assert len(markers) >= 9, f"Expected 9 query markers (-- Q1 through -- Q9), found {len(markers)}"


def test_schema_loads():
    result = subprocess.run(
        ["psql", "-h", "localhost", "-U", "postgres", "-d", "levant_tech", "-f", "schema.sql"],
        capture_output=True, text=True,
        env={"PGPASSWORD": "postgres", "PATH": "/usr/bin:/usr/local/bin"}
    )
    assert result.returncode == 0, f"Schema load failed: {result.stderr}"


def test_seed_data_loads():
    result = subprocess.run(
        ["psql", "-h", "localhost", "-U", "postgres", "-d", "levant_tech", "-f", "seed_data.sql"],
        capture_output=True, text=True,
        env={"PGPASSWORD": "postgres", "PATH": "/usr/bin:/usr/local/bin"}
    )
    assert result.returncode == 0, f"Seed data load failed: {result.stderr}"


def test_queries_execute():
    result = subprocess.run(
        ["psql", "-h", "localhost", "-U", "postgres", "-d", "levant_tech", "-f", "queries.sql"],
        capture_output=True, text=True,
        env={"PGPASSWORD": "postgres", "PATH": "/usr/bin:/usr/local/bin"}
    )
    assert result.returncode == 0, f"queries.sql execution failed: {result.stderr}"
