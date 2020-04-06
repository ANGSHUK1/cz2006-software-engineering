from flask import Blueprint
from flask_restful import Api

from controllers import \
    user_controllers, route_controllers, point_controllers, algo_controllers

user_bp = Blueprint('user', __name__)
api_user = Api(user_bp)
api_user.add_resource(user_controllers.userAPI, '/')
api_user.add_resource(user_controllers.userAPI_byID, '/id/')
api_user.add_resource(user_controllers.userPasswordAPI, '/password/')

route_bp = Blueprint('route', __name__)
api_route = Api(route_bp)
api_route.add_resource(route_controllers.routeAPI, '/')
api_route.add_resource(point_controllers.pointAPI, '/points/')

algo_bp = Blueprint('algo', __name__)
api_algo = Api(algo_bp)
api_algo.add_resource(algo_controllers.RoutesSearchAlgoAPI, '/routes_search/')
api_algo.add_resource(algo_controllers.PopularRoutesAlgoAPI, '/popular_routes/')
api_algo.add_resource(algo_controllers.LiveStatsAlgoAPI, '/live_stats/')
