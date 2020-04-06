"""empty message

Revision ID: 30b6137fa284
Revises: 01c8ed6c7476
Create Date: 2020-04-07 03:32:01.441942

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '30b6137fa284'
down_revision = '01c8ed6c7476'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_foreign_key(None, 'routes', 'points', ['endPos'], ['id'])
    op.create_foreign_key(None, 'routes', 'points', ['startPos'], ['id'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'routes', type_='foreignkey')
    op.drop_constraint(None, 'routes', type_='foreignkey')
    # ### end Alembic commands ###