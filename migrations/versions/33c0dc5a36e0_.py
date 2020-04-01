"""empty message

Revision ID: 33c0dc5a36e0
Revises: 3cef84855e82
Create Date: 2020-03-23 15:02:34.550904

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '33c0dc5a36e0'
down_revision = '3cef84855e82'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('routes', sa.Column('user_id', sa.Integer(), nullable=False))
    op.create_unique_constraint(None, 'users', ['username'])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'users', type_='unique')
    op.drop_column('routes', 'user_id')
    # ### end Alembic commands ###